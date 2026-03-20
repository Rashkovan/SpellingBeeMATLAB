# Introduction
For our CLPS950 group project, we attempted to create a game in MATLAB that was a crossover between Spelling Bee and 
Hangman. For our repo, the main aspect of the game is making a valid English word betwen 4 and 7 letters that followed the 
theme of animal and used a mandatory center letter. You must follow the rules of creating a valid word or gain a strike, 
and you lose the game if you have too many strikes. In order to win, you must completely fill the bee with color, or in 
other words, gain enough points. 


### *Components of the Game*
We have created a UI (in spelling_bee_ui_draft.m) that contains these items: 
- tracks the words created
- a heading labeled with the theme
- a heading linked to the scoring
- a hexagon "comb" shape to comtain the letters with a center letter
- a bee design that acts as a the word counter system (by filling in the bee with color every 2 points gained)
- a shuffle button for the letters
- a box for the number of strikes a player has (that functions as a penalty counter where players "lose a life" if their word does not fulfill the conditions of the word validation feature)
- a game over screen depending on win or loss
- an option to restart the game after the game over screen

The images for the UI are rotated and listed under the .png files. Additonally, we implemented a word validation feature 
(in word_validation.m), where players receive feedback if their submitted word fails to meet the rules of the game. 
This feature pulls from a word list (in wordList.txt & word_list_puzzle.m) we created with all the possible combinations of 
letters as well as a themed list (in themeWords.txt) with all words from the word list that follow our theme. The players' 
points are scored (in scoring4project.m) by the number of valid words created, with one point for a word and four points for 
the pangram, which is HAMSTER. In order to win, the score must be 10. We created a final version of the game with all its 
components in Bee_Launch.m and the function to launch  the game in Game_Launcher_Final.m


[Loom Video](https://www.loom.com/share/6f00940c53c545839f7d68650e3eb7a0)


# Deliverable 
Throughout this project, the biggest challenge has been creating a UI that's compatible with our game due to the images and
design we wanted. However, we were able to use the applications feature to implement the different images we wanted such as
coloring in the bee with every point gained until victory. There were a lot of issues that arose; for example, the images 
initialization, resetting the game, even entering words. We were able to debug all these errors which we think was also
our biggest triumph. The miniscule bugs that led to malfunctions were frustrating at times, but we persevered and worked
together to find and debug them. Nonetheless, we really enjoyed the process of creating this game and adding new featues to
the existing spelling bee. The end result was exactly as we envisioned, so we hope you enjoy playing it 

This is a step-by-step process of us completing the game as well as showing the features it contains:

1. To start off the game!
![1. This is the starting screen](https://github.com/Rashkovan/SpellingBeeMATLAB/blob/main/deliverablegamepngs/baseuinewnew.png)

2. After using the shuffle button to get a new perspective:
![shuffle](https://github.com/Rashkovan/SpellingBeeMATLAB/blob/main/deliverablegamepngs/shuffledletters.png)

3. Let's try putting in some words!
![gainpts](https://github.com/Rashkovan/SpellingBeeMATLAB/blob/main/deliverablegamepngs/gainedpts_coloredbee.png)
I got 2 valid words, and it colored the bee in!!

4. Let's come up with some more words
![errors](https://github.com/Rashkovan/SpellingBeeMATLAB/blob/main/deliverablegamepngs/strike_unavailletter.png)
Oh no, I accidentally used a letter that's not here, let's try again

![errors](https://github.com/Rashkovan/SpellingBeeMATLAB/blob/main/deliverablegamepngs/strike_invalidword.png)
Oh, it's not a valid English word...

5. I received too many strikes :( It's okay, we can just restart!
![loss](https://github.com/Rashkovan/SpellingBeeMATLAB/blob/main/deliverablegamepngs/gameover_loss.png)

6. That's more like it!
![win](https://github.com/Rashkovan/SpellingBeeMATLAB/blob/main/deliverablegamepngs/gameover_win.png "YAY!")
