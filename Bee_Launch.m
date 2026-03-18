classdef Bee_Launch < matlab.apps.AppBase

% single launch file 
% BEE_LAUNCH  Spelling Bee + Hangman combo game 
%
% Run with:   app = Bee_Launch;
%
% Integrates:
%   word_list_puzzle.m  ->  loadPuzzleData()   (private method)
%   word_validation.m   ->  validateWord()     (private method)
%                       ->  checkLettersAllowed()  (private helper)
%   scoring4project.m   ->  scoreWord()        (private method)
%   spelling_bee_ui_draft.m  ->  all UI components + callbacks
%
% Fixes applied on merge:
% validateWord: removed duplicate checkLettersAllowed call
% loadPuzzle: added wordPoints 
% scoring: removed command-line input() loop; now a pure pts function
% UI: added Submit button so validation should fire on submit, not keystroke 
% UI: bee thresholds now scale to actual max score, not hardcoded 10
% UI: startupFcn now seeds puzzle data and live letter display

    %  UI COMPONENT 
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        % top bar 
        SCORELabel          matlab.ui.control.Label
        scorecounter        matlab.ui.control.Label
        THEMELabel          matlab.ui.control.Label
        AnimalsLabel        matlab.ui.control.Label
        STRIKESLabel        matlab.ui.control.Label
        strikecounter       matlab.ui.control.Label
        % center 
        blankbee            matlab.ui.control.Image
        wordwheel           matlab.ui.control.Image
        % input row 
        GUESSLabel          matlab.ui.control.Label
        inputfield          matlab.ui.control.EditField
        submitbutton        matlab.ui.control.Button   % NEW — was missing
        shufflebutton       matlab.ui.control.Button
        % word list 
        WordsFoundLabel     matlab.ui.control.Label
        WordsListBox        matlab.ui.control.ListBox
        % feedback bar 
        FeedbackLabel       matlab.ui.control.Label    % NEW — replaces fprintf
    end

    % =====================================================================
    %  GAME STATE
    % =====================================================================
    properties (Access = private)
        Score    = 0
        Strikes  = 0      % renamed from Penalties for clarity
        FoundWords = {}
        Puzzle            % struct: availableLetters, centerLetter, pangram,
                          %        themeWords, wordPoints, maxScore
        MaxStrikes = 5
    end

    % =====================================================================
    %  CALLBACKS
    % =====================================================================
    methods (Access = private)

        % -----------------------------------------------------------------
        % STARTUP — runs once after all components are created
        % -----------------------------------------------------------------
        function startupFcn(app)
            app.Puzzle = app.loadPuzzleData();

            % Reset display
            app.Score   = 0;
            app.Strikes = 0;
            app.FoundWords = {};

            app.scorecounter.Text  = '0';
            app.strikecounter.Text = '0';
            app.WordsListBox.Items = {};
            app.FeedbackLabel.Text = '';

            app.updateBeeImage();

            app.blankbee.ImageSource = fullfile(pathToApp, 'bee1.png');

            app.wordwheel.ImageSource = fullfile(pathToApp, 'word wheel.png');

            % Seed theme label
            app.AnimalsLabel.Text = 'Animals';   % TODO: pull from puzzle
        end

        % -----------------------------------------------------------------
        % SUBMIT BUTTON — validates word and updates all game state
        % Also fires if user presses Enter in the input field
        % -----------------------------------------------------------------
        function onSubmit(app, ~, ~)
            raw = strtrim(app.inputfield.Value);
            if isempty(raw), return, end

            word = lower(raw);

            % wordList = themeWords for this puzzle.
            % TODO: swap wordList for a full English dictionary .txt load
            wordList = app.Puzzle.themeWords;

            [isValid, msg] = app.validateWord( ...
                word, ...
                app.Puzzle.centerLetter, ...
                app.Puzzle.availableLetters, ...
                wordList, ...
                app.Puzzle.themeWords, ...
                app.FoundWords);

            if isValid
                pts = app.scoreWord(word);
                app.Score = app.Score + pts;
                app.FoundWords{end+1} = word;

                % Refresh score display
                app.scorecounter.Text = num2str(app.Score);

                % Refresh word list (sorted alphabetically)
                app.WordsListBox.Items = sort(app.FoundWords);

                % Show feedback with points earned
                if pts > app.Puzzle.wordPoints(word)
                    app.showFeedback(sprintf('PANGRAM! +%d points!', pts), [0.2 0.7 0.3]);
                else
                    app.showFeedback(sprintf('%s  (+%d)', msg, pts), [0.2 0.7 0.3]);
                end

                % Check win
                if app.Score >= app.Puzzle.maxScore
                    app.showFeedback('You reached GENIUS! You win!', [0.93 0.69 0.13]);
                    app.blankbee.ImageSource = 'bee6.png';
                    app.submitbutton.Enable  = 'off';
                    app.inputfield.Enable    = 'off';
                end

            else
                % Invalid word — count as a strike
                app.Strikes = app.Strikes + 1;
                app.strikecounter.Text = num2str(app.Strikes);
                app.showFeedback(msg, [0.85 0.33 0.33]);

                % Check loss
                if app.Strikes >= app.MaxStrikes
                    app.showFeedback('Too many strikes! Game over.', [0.85 0.1 0.1]);
                    app.blankbee.ImageSource = 'bee1.png';
                    app.submitbutton.Enable  = 'off';
                    app.inputfield.Enable    = 'off';
                end
            end

            app.updateBeeImage();
            app.inputfield.Value = '';   % clear input after every submit
        end

        % -----------------------------------------------------------------
        % SHUFFLE BUTTON — cycles word wheel image
        % -----------------------------------------------------------------
        function shufflebuttonButtonPushed(app, ~, ~)
            imgNum = randi([1, 7]);
            app.wordwheel.ImageSource = sprintf('word wheel%d.png', imgNum);
        end

    end   % callbacks

    % =====================================================================
    %  GAME LOGIC  (ported from separate .m files, now private methods)
    % =====================================================================
    methods (Access = private)

        % loadPuzzleData  (from word_list_puzzle.m)
        function puzzle = loadPuzzleData(~)

            puzzle.availableLetters = 'smtareh';
            puzzle.centerLetter     = 'a';
            puzzle.pangram          = 'hamster';

        fourLetters = { ...
            'ears',  'east',  'eats',  'eras',  'hams',  'hare', ...
            'hart',  'hate',  'hats',  'hear',  'heat',  'mare', ...
            'mars',  'mart',  'mash',  'mast',  'math',  'mate', ...
            'meat',  'rash',  'rate',  'rats',  'rhea',  'same', ...
            'seam',  'sear',  'seat',  'star',  'tame',  'team', ...
            'tear' , 'rame' ...
        };
    
        fiveLetters = { ...
            'earth',  'harem',  'harts',  'hater',  'hates',  'hears', ...
            'heart',  'heats',  'mares',  'maths',  'mater',  'mates', ...
            'meats',  'rates',  'rheas',  'share',  'shear',  'smart', ...
            'smear',  'stare',  'steam',  'tamer',  'tames',  'teams', ...
            'ramet',  ... 
        };
    
        sixLetters = { ...
            'earths',  'harems',  'haters',  'hearts',  'master', ...
            'maters',  'stream',  'tamers' , 'ramets' ...
        };
    
        sevenLetters = { ...
            'hamster', 'mathers' ...
        };


            puzzle.themeWords = [ ...
                fourLetters, fiveLetters, sixLetters, sevenLetters];

            %  build wordPoints map 
            % This was missing entirely from the original word_list_puzzle.m
            puzzle.wordPoints = containers.Map( ...
                'KeyType', 'char', 'ValueType', 'double');

            for i = 1:length(puzzle.themeWords)
                w = puzzle.themeWords{i};
                puzzle.wordPoints(w) = app.scoreWord(w);
            end

            % Max possible score: sum of all word points
            allPts = cell2mat(values(puzzle.wordPoints));
            puzzle.maxScore = sum(allPts);
        end

        % validateWord  (was: word_validation.m)
        % removed duplicate checkLettersAllowed call
        function [isValid, message] = validateWord(app, word, centerLetter, ...
                availableLetters, wordList, themeWords, usedWords)

            word             = lower(strtrim(word));
            centerLetter     = lower(centerLetter(1));
            availableLetters = lower(availableLetters);
            isValid          = false;

            % Minimum length
            if length(word) < 4
                message = 'Too short! Need at least 4 letters.';
                return
            end

            % Must contain center letter
            if ~any(word == centerLetter)
                message = sprintf('Must use the center letter "%s"!', ...
                    upper(centerLetter));
                return
            end

            % Only allowed letters  [was called twice — now called once]
            [ok, bad] = app.checkLettersAllowed(word, availableLetters);
            if ~ok
                message = sprintf('"%s" is not one of your letters!', upper(bad));
                return
            end

            % Not already found
            if ismember(word, usedWords)
                message = 'Already found that one!';
                return
            end

            % Real word
            if ~ismember(word, wordList)
                message = 'Not a recognized word.';
                return
            end

            % Matches theme
            if ~ismember(word, themeWords)
                message = 'Doesn''t fit the theme — try again!';
                return
            end

            isValid = true;
            message = 'Nice word!';
        end

        % checkLettersAllowed  (helper from word_validation.m)
        function [allAllowed, firstBad] = checkLettersAllowed(~, word, available)
            allAllowed = true;
            firstBad   = '';
            for i = 1:length(word)
                if ~ismember(word(i), available)
                    allAllowed = false;
                    firstBad   = word(i);
                    return
                end
            end
        end

        % scoreWord  (was: scoring4project.m)
        % Scoring: 4-letter = 1pt, 5+ = 1pt per letter, pangram = +7 bonus
        function pts = scoreWord(app, word)
            if length(word) == 4
                pts = 1;
            else
                pts = length(word);
            end
            % Pangram bonus: word uses every letter in the pangram
            if all(ismember(char(app.Puzzle.pangram), char(word)))
                pts = pts + 7;
            end
        end

        % UPDATED!! 
        % updateBeeImage  — scales bee stage to actual max score
        function updateBeeImage(app)
            if app.Puzzle.maxScore == 0, return, end
            pct = app.Score / app.Puzzle.maxScore; 

            if pct >= 1.0
                app.blankbee.ImageSource = 'bee6.png';
            elseif pct >= 0.7
                app.blankbee.ImageSource = 'bee5.png';
            elseif pct >= 0.5
                app.blankbee.ImageSource = 'bee4.png';
            elseif pct >= 0.3
                app.blankbee.ImageSource = 'bee3.png';
            elseif pct >= 0.1
                app.blankbee.ImageSource = 'bee2.png';
            else
                app.blankbee.ImageSource = 'spelling bee clear.png';
            end
        end

        % showFeedback — display a message in the feedback bar
        function showFeedback(app, msg, color)
            app.FeedbackLabel.Text      = msg;
            app.FeedbackLabel.FontColor = color;
        end

    end   

    %  UI CONSTRUCTION  (from spelling_bee_ui_draft.m)
    methods (Access = private)

        function createComponents(app)

            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Figure 
            app.UIFigure          = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name     = 'Spelling Bee';

            % Top bar: Score 
            app.SCORELabel = uilabel(app.UIFigure, ...
                'Text', 'SCORE:', 'FontName', 'Andale Mono', 'FontSize', 24, ...
                'Position', [44 396 91 32]);

            app.scorecounter = uilabel(app.UIFigure, ...
                'Text', '0', 'FontName', 'Andale Mono', 'FontSize', 24, ...
                'Position', [140 396 80 32]);

            % Top bar: Theme 
            app.THEMELabel = uilabel(app.UIFigure, ...
                'Text', 'THEME:', 'FontName', 'Andale Mono', 'FontSize', 24, ...
                'FontColor', [0.15 0.15 0.15], 'Position', [44 360 91 32]);

            app.AnimalsLabel = uilabel(app.UIFigure, ...
                'Text', 'Animals', 'FontName', 'Andale Mono', 'FontSize', 24, ...
                'FontColor', [0.93 0.69 0.13], 'Position', [140 360 160 32]);

            % Top bar: Strikes 
            app.STRIKESLabel = uilabel(app.UIFigure, ...
                'Text', 'STRIKES:', 'FontName', 'Andale Mono', 'FontSize', 24, ...
                'Position', [420 396 130 32]);

            app.strikecounter = uilabel(app.UIFigure, ...
                'Text', '0', 'FontName', 'Andale Mono', 'FontSize', 24, ...
                'Position', [556 396 48 32]);

            % Bee image 
            app.blankbee = uiimage(app.UIFigure, ...
                'Position', [263 344 116 118], ...
                'ImageSource', fullfile(pathToMLAPP, 'spelling bee clear.png'));

            % Word wheel 
            app.wordwheel = uiimage(app.UIFigure, ...
                'Position', [188 92 278 244], ...
                'ImageSource', fullfile(pathToMLAPP, 'word wheel.png'));

            % Words found list 
            app.WordsFoundLabel = uilabel(app.UIFigure, ...
                'Text', 'Words:', 'HorizontalAlignment', 'right', ...
                'FontName', 'Andale Mono', 'FontSize', 18, ...
                'Position', [465 355 70 24]);

            app.WordsListBox = uilistbox(app.UIFigure, ...
                'FontName', 'Andale Mono', 'FontSize', 14, ...
                'Position', [550 90 79 261]);

            % Feedback bar (new — replaces fprintf) 
            app.FeedbackLabel = uilabel(app.UIFigure, ...
                'Text', '', 'FontName', 'Andale Mono', 'FontSize', 14, ...
                'HorizontalAlignment', 'center', ...
                'Position', [188 70 278 22]);

            %  Input row 
            app.GUESSLabel = uilabel(app.UIFigure, ...
                'Text', 'GUESS:', 'HorizontalAlignment', 'right', ...
                'FontName', 'Andale Mono', 'FontSize', 24, ...
                'Position', [188 35 95 32]);

            app.inputfield = uieditfield(app.UIFigure, 'text', ...
                'FontSize', 24, 'Position', [288 32 140 35], ...
                'ValueChangedFcn', createCallbackFcn(app, @onSubmit, true));
            %  ValueChangedFcn fires on Enter key — correct trigger for submit

            % Submit button (was missing — validation must be intentional)
            app.submitbutton = uibutton(app.UIFigure, 'push', ...
                'Text', 'ENTER', 'FontName', 'Andale Mono', 'FontSize', 14, ...
                'Position', [434 32 80 35], ...
                'ButtonPushedFcn', createCallbackFcn(app, @onSubmit, true));

            % Shuffle button
            app.shufflebutton = uibutton(app.UIFigure, 'push', ...
                'Icon', fullfile(pathToMLAPP, 'shuffle button.png'), ...
                'Text', '', 'Position', [130 21 63 57], ...
                'ButtonPushedFcn', createCallbackFcn(app, @shufflebuttonButtonPushed, true));

            app.UIFigure.Visible = 'on';
        end

    end   

    %  APP LIFECYCLE
    methods (Access = public)

        function app = Bee_Launch
            createComponents(app)
            registerApp(app, app.UIFigure)
            runStartupFcn(app, @startupFcn)
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end

    end

end
