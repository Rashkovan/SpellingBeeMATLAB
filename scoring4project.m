function [pts, msg] = score (word, foundWords)

pangram = "HAMSTER";  %identify pangram
winScore = 10;      %identify score to win = 10 points
totalScore = 0;

if word == pangram
    pts = 4;
    msg = "You got the pangram! Great work!";
else
    pts = 1;
    msg = "Awesome! That was a valid word.";
end

while totalScore < winScore     %loop continues if player hasn't reached 10 pts
    guess = input("Enter a word: ", "s");   %prompt player to enter word
    fprintf("%s\n", msg); %print feedback msg

    if pts > 0  %runs when word is valid & earns pts
            totalScore = totalScore + pts;  %adds the earned points to total score
                 fprintf("You earned %d point(s). Total = %d\n\n", pts, totalScore);
                    %shows points earned & updated total score
    else
        fprintf("No points earned. \n\n");
    end

    if totalScore >= winScore
        fprintf("Congratulations! You reached 10 points and won the game! \n");
        break; %game ends
    end
end