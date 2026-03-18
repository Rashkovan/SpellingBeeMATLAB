%% WORD validation ]
% this file should store only validateWord and checkLettersAllowed helpers. 

function [isValid, message] = validateWord(word, centerLetter, availableLetters, wordList, themeWords, usedWords)
  % VALIDATEWORD  Validates a player's submitted word.
  %
  % INPUTS:
  %   word: the word the player typed
  %   centerLetter: the mandatory center letter (1 char)
  %   availableLetters: all 7 allowed letters, e.g. 'smtareh'
  %   wordList: full dictionary of valid words
  %   themeWords: subset matching the theme
  %   usedWords: words already found this game
  % OUTPUTS:
  %   isValid: true only if ALL checks pass
  %   message:  feedback shown to the player
  % CHECKS (in order — first failure exits early):
    %  Minimum 4 letters
    %  Contains the center letter
    %  Only uses letters from the available set (repeats allowed)
    %  Not already used this game
    %  Is a real word (in wordList)
    %  Matches the theme (in themeWords)

    % normalize to case-sensitive 
    word             = lower(strtrim(word));
    centerLetter     = lower(centerLetter(1));   
    availableLetters = lower(availableLetters);

    isValid = false;

      % Minimum length (>= 4 letters)
      if length(word) < 4
          message = 'Too short! Words must be at least 4 letters.';
          return;
      end

      % Must contain the center letter A
      if ~any(word == centerLetter)
          message = sprintf('Must use the center letter "%s"!', upper(centerLetter));
          return;
      end

      % Every letter must be from the available set (reuse allowed)
      [lettersOK, badLetter] = checkLettersAllowed(word, availableLetters);
      if ~lettersOK
          message = sprintf('"%s" is not one of your letters!', upper(badLetter));
          return;
      end

      % Every letter must come from the available set (reuse is fine)
       [lettersOK, badLetter] = checkLettersAllowed(word, availableLetters);
    if ~lettersOK
        message = sprintf('"%s" is not one of your letters!', upper(badLetter));
        return
    end

% used in the game already 
if ismember(word, usedWords)
        message = 'Already found that one!';
        return
    end

      % Must be a real word
      if ~ismember(word, wordList)
        message = 'Not a recognized word.';
        return
    end

      % Must match the theme
if ~ismember(word, themeWords)
        message = 'Doesn''t fit the theme — try again!';
        return
    end

    % All checks passed
    isValid = true;
    message = 'Nice word!';
 
end

%% checkLettersAllowed 
% every letter in the word must appear somewhere in the 7-letter set,
% letter can be used more than once.

% INPUTS:
%   word           
%   availableLetters
% OUTPUTS:
%   allAllowed     : true if every letter in word is in availableLetters
%   firstBadLetter : the first offending character ('' if allAllowed)

function [allAllowed, firstBadLetter] = checkLettersAllowed(word, availableLetters)
 
    allAllowed     = true;
    firstBadLetter = '';
 
    for i = 1:length(word)
        letter = word(i);
        if ~ismember(letter, availableLetters)
            allAllowed     = false;
            firstBadLetter = letter;
            return   % stop at first bad letter
        end
    end
 
end
