# Practical 1: A Markov Text Model
New translations of the bible into modern English always arouse controversy. Proponents of the new translation
argue that it makes the text more understandable, while opponents argue that the new text merely removes the
rhythm and poetry of the language while making it no more accessible. There are various ways of testing claims
about understandability. One test is to see how readily readers can distinguish genuine text from the book, with
computer generated text designed to match word patterns seen in the book, but generated randomly so that it
contains no actual meaning.

This practical is about creating such computer generated text. The idea is to use a 2nd order Markov model
— that is a model in which we generate words sequentially, with the each word being drawn with a probability
dependent on the words preceding it. The probabilities are obtained by training the model on the actual text. That
is by simply tabulating the frequency with which each word follows any other pair of words.

To make this work requires simplification. The model will not cover every word used in the text. Rather the
model’s ‘vocabulary’ will be limited to the m most common words. m ≈ 500 is sensible. Suppose that the m most
common words are in a vector b. Let a be the vector of all words in the Bible. We will construct an m × m × m
array A, such that

$$P(a_t = b_j |a_{t−1} = b_k, a_{t−2} = b_i) = T_{ikj}$$ .

Given T, b and a pair of starting words from b, you can then iterate to generate text from the model. That is, given
a word bi followed by a word bk, the following word has probability Tikj of being bj . To generate an appropriate
bj , we use the sample function to sample a word from b with probabilities given by T[i,k,]. To estimate T
you need to go through the text of the bible, counting up the number of times bj follows sequential word pairs
bi, bk for all words in b.
