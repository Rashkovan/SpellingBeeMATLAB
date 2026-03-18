# Introduction
For our CLPS950 group project, we attempted to create a game in MATLAB that was a crossover between Spelling Bee and 
Hangman. For our repo, the main aspect of the game is making a valid English word betwen 4 and 7 letters that followed the 
theme of animal and used a mandatory center letter. You must follow the rules of creating a valid word or lose a life, 
and you lose the game if you lose all your lives. In order to win, you must completely fill the bee with color, or in 
other words, gain enough points. 


### *Components of the Game*
We have created a UI (in spelling_bee_ui_draft.m) that contains these items: 
- tracks the words created
- a heading labeled with the theme
- a bee design that acts as a the word counter system
- a shuffle button for the letters
- a box for the number of strikes a player has (that functions as a penalty counter where players "lose a life" if their word does not fulfill the conditions of the word validation feature)
- a game over screen depending on win or loss

Additonally, we implemented a word validation feature (in word_validation.m), where players receive feedback if their
submitted word fails to meet the rules of the game. This feature pulls from a word list (in wordList.txt &
word_list_puzzle.m) we created with all the possible combinations of letters as well as a themed list (in themeWords.txt)
with all words from the word list that follow our theme. The players' points are scored (in scoring4project.m) by the number
of valid words created, with one point for a word and four points for the pangram, which is HAMSTER. In order to win, the
score must be 10. We created a final version of the game with all its components in Bee_Launch.m and the function to launch 
the game in Game_Launcher_Final.m


# Deliverable 
Throughout this project, the biggest challenge has been creating a UI that's compatible with our game due to the images and
design we wanted. However, we were able to use the applications feature to implement the different images we wanted such as
coloring in the bee with every point gained until victory. Our biggest triumph was 

This is a step-by-step process of us completing the game:

1. 
