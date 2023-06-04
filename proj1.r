#name ; university user name ; 
#Shiyu Cai ; s2307982
#Yifan Wu ; s2316499
#Yifan Cai ; s2301729
#Shiyu Cai: Data preprocessing, including separation of words and punctuation in sentences and generation of vectors a and b. And modify the version of b for the "capital" issue.
#Yifan Wu: Create triplet, doublet, matrix T, A and vector S. And modify the version of b for the "capital" issue.
#Yifan Cai:Simulate 50-words sections from model and directly from vector S respectively. And compare these 2 sections. And modify the version of b for the "capital" issue.


library(stringr)
setwd("/Users/eavan/Desktop/statistical programming /sp-proj1")##set work path as local repo, please change the directory before run the code
##read file content and skip first 104 lines
a <- scan("pg10.txt", what = "character", skip = 104) 
n <- length(a)##set n as the length of a
a <- a[-((n - 2886):n)]##strip license
a <- a[-grep("[0123456789]:[0123456789]", a)]##strip out verse numbers
split_punct <- function(vector_word, punct_mark){##create function to split string into a combination of word and punctuation 
    ip <- grep(punct_mark, vector_word)
    new_vec <- rep("", length(ip)+length(vector_word))
    iip <- ip + 1:length(ip) 
    new_vec[-iip] <- gsub(punct_mark,"",vector_word)
    new_vec[iip] <- substr(vector_word[ip],nchar(vector_word[ip]),nchar(vector_word[ip]))
    new_vec
}

a_new1 <- split_punct(a, "[\\,\\.\\;\\!\\:\\?]")##apply the function to a 
a_new2 <- tolower(a_new1)##define a_new2 as all lowercase words in a_new1
b <- unique(a_new2)####find unique words in a_new2
index_vector1 <- match(a_new1,b)##find the index of which element in b each element of a_new1 corresponds to
index_vector2 <- match(a_new2,b)##find the index of which element in b each element of a_new2 corresponds to
freq1 <- tabulate(index_vector1)##count up how many times each unique word occurs in a_new1
freq2 <- tabulate(index_vector2)##count up how many times each unique word occurs in a_new2
ratio_mat <- freq1/freq2
b[ratio_mat<0.5]<-str_to_title(b[ratio_mat<0.5])##to let the words that most often start with a capital letter still start with a capital letter
threshold<-sort(freq2,decreasing = TRUE)[500]##set a threshold to find the most 500 common words
b <- b[freq2>=threshold]##find the most 500 common words in b
index_vector3<-match(a_new2,b)##find the index of which element in b each element of a_new2 corresponds to
##create a three column matrix
tri_matrix<-cbind(index_vector3[1:(length(index_vector3)-2)],index_vector3[2:(length(index_vector3)-1)],index_vector3[3:length(index_vector3)])
tri_matrix<-tri_matrix[is.na(rowSums(tri_matrix))==FALSE,1:3]#delete the NA row
i<-length(b)##define the value of i
k<-length(b)##define the value of k
j<-length(b)##define the value of j
T<-rep(0,i*k*j)#create the matrix T
dim(T) <- c(i,k,j)#Transformation to the corresponding shape
##Calculation of frequency
for (s in 1:(dim(tri_matrix)[1])){
T[tri_matrix[s,1],tri_matrix[s,2],tri_matrix[s,3]]<-T[tri_matrix[s,1],tri_matrix[s,2],tri_matrix[s,3]]+1
}
T<-T/sum(T)##calculate the probability 
##create a two column matrix
tri_matrix2<-cbind(index_vector3[1:(length(index_vector3)-1)],index_vector3[2:(length(index_vector3))])
tri_matrix2<-tri_matrix2[is.na(rowSums(tri_matrix2))==FALSE,1:2]#delete the NA row
A<-rep(0,i*j)#create the matrix A
dim(A) <- c(i,j)#Transformation to the corresponding shape
##Calculation of frequency
for (s in 1:(dim(tri_matrix2)[1])){
  A[tri_matrix2[s,1],tri_matrix2[s,2]]<-A[tri_matrix2[s,1],tri_matrix2[s,2]]+1
}
A<-A/sum(A)##calculate the probability 
##create a vector 
tri_matrix3<-index_vector3[is.na(index_vector3)==FALSE]
S<-rep(0,i)#create the vector S 
##Calculation of frequency
for (s in (1:length(tri_matrix3))){
  S[tri_matrix3[s]]<-S[tri_matrix3[s]]+1
}
S<-S/sum(S)##calculate the probability 

##to simulate 50-words sections from model
sections=rep(0,50)##creat a vector to store indexes of 50-words 
set.seed(1)
sections[1]=sample(1:length(S),1,prob=S,replace = TRUE) ##find the first word with a given probability in S
##generate the second word
##there are 2 possible situations of the second word:
##1.we find it in the word pair matrix(tri_matrix2) from the single previous word 
##2.if 1 does not success, we should find it in the word vector(tri_matrix3) 
if (sum(A[sections[1],])==0){
  sections[2]=sample(1:length(S),1,prob=S,replace = TRUE)
}else{
  sections[2]=sample(1:length(A[sections[1],]),1,prob = A[sections[1],],replace = TRUE)
} 

## generate the following 47 words 
##there might be 3 possible situations of the following word:
##1.we find it in the triplet(tri_matrix3) from the previous word pair
##2.if 1 does not success, we should find it in the word pair matrix(tri_matrix2) from just the single previous word 
##3.if 2 still does not success, we should find it in the word vector(tri_matrix3) 
##repeat the above 3 steps until we have all 50 suitable indexes 
m=3;##index of the newly created word
repeat{
  if (sum(T[sections[m-2],sections[m-1],])==0) {
    if (sum(A[sections[m-1],])==0){
      sections[m]=sample(1:length(S),1,prob=S,replace = TRUE)
    }else{
      sections[m]=sample(1:length(A[sections[m-1],]),1,prob = A[sections[m-1],],replace = TRUE)
    }
  } else{
    sections[m]=sample(1:length(T[sections[m-2],sections[m-1],]),1,prob = T[sections[m-2],sections[m-1],],replace = TRUE)
  }
  m<-m+1
  if (m>50) break
}
cat(sections)##print indexes of 50-words 
word_sections=rep("",50)##create a vector to store simulated 50-words from model
word_sections_s=rep("",50)##create a vector to store simulated 50 word sections of text where the word probabilities are simply taken from S

for (i in 1:50) {
  word_sections[i]=b[sections[i]]##match each word in b based on its index
}
cat(word_sections)##print simulated 50-words from model
sections_s=sample(1:length(S),50,prob=S,replace = TRUE)##sample 50 word sections directly from S 
for (i in 1:50) {
  word_sections_s[i]=b[sections_s[i]]##match each word in b based on its index
}
cat(word_sections_s)##print 50 word sections of text where the word probabilities are simply taken from S

##Obviously, generated word_sections_s is a combination of words without logic, while word_sections is a group of words or even short sentences with logic

