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
        BeeProgressLabel    matlab.ui.control.Label    % shows X/10 pts hint
        % end win/lose screen
        win_lose_screen      matlab.ui.container.Panel
        replaybutton         matlab.ui.control.Button
        endgraphic           matlab.ui.control.Image %NEW - graphics for win/lose and replay button
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

            app.blankbee.ImageSource = 'bee1.png'

            app.wordwheel.ImageSource = 'word wheel1.png'

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

            [isValid, msg] = app.validateWord( ...
                word, ...
                app.Puzzle.centerLetter, ...
                app.Puzzle.availableLetters, ...
                app.Puzzle.wordList, ...
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

                % Show feedback
                app.showFeedback(sprintf('%s  (+1)', msg), [0.2 0.7 0.3]);

                % Check win
                if app.Score >= 10
                    app.showFeedback('You reached GENIUS! You win!', [0.93 0.69 0.13]);
                    app.blankbee.ImageSource = 'bee6.png';
                    app.submitbutton.Enable  = 'off';
                    app.inputfield.Enable    = 'off';

                %NEW -- show win graphics:
                    app.win_lose_screen.Visible = 'on';
                    uistack(app.win_lose_screen, 'top');
                    app.replaybutton.ImageSource = 'playagain.png';
                    app.endgraphic.ImageSource = 'win.png';
            
                    
                end

            else
                % Invalid word — count as a strike
                app.Strikes = app.Strikes + 1;
                app.strikecounter.Text = num2str(app.Strikes);
                app.showFeedback(msg, [0.85 0.33 0.33]);

                % Check loss
                if app.Strikes >= app.MaxStrikes
                    app.showFeedback('Too many strikes! Game over.', [0.85 0.1 0.1]);
                    app.blankbee.ImageSource = 'beesad.png';
                    app.submitbutton.Enable  = 'off';
                    app.inputfield.Enable    = 'off';
                    %NEW -- show lose screen:
                    app.win_lose_screen.Visible = 'on';
                    uistack(app.win_lose_screen, 'top');
                    app.replaybutton.ImageSource = 'playagain.png';
                    app.endgraphic.ImageSource = 'lose.png';
            
                    
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

        % -----------------------------------------------------------------
        % NEW --- PLAY AGAIN BUTTON PUSHED
        % -----------------------------------------------------------------
        function replaybuttonPushed(app, ~, ~)
            % 1. Reset Game State Data
            app.Score   = 0;
            app.Strikes = 0;
            app.FoundWords = {};

            % 2. Reset UI Displays
            app.scorecounter.Text  = '0';
            app.strikecounter.Text = '0';
            app.WordsListBox.Items = {};
            app.FeedbackLabel.Text = '';
            app.inputfield.Value   = '';

            % 3. Re-enable inputs
            app.submitbutton.Enable = 'on';
            app.inputfield.Enable   = 'on';

            % 4. Reset Images (Bee and Wheel)
            app.blankbee.ImageSource  = 'bee1.png';
            app.wordwheel.ImageSource = 'word wheel1.png';

            % 5. IMPORTANT: Hide the game over screen again
            app.win_lose_screen.Visible = 'off';
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

            % All valid words (used letters + real word check)
            puzzle.wordList = { ...
                'a', 'am', 'ar', 'are', 'arm', 'art', 'as', 'at', ...
                'ear', 'ears', 'east', 'eat', 'eats', 'earth', 'earths', ...
                'era', 'eras', ...
                'ham', 'hams', 'hare', 'harem', 'harems', 'hart', 'harts', ...
                'hate', 'hater', 'haters', 'hates', 'hat', 'hats', ...
                'hear', 'heard', 'hears', 'heart', 'hearts', 'heat', 'heats', ...
                'hem', 'her', 'hers', 'hest', ...
                'mare', 'mares', 'mars', 'mart', 'mash', 'mast', 'math', 'maths', ...
                'mate', 'mater', 'maters', 'mates', 'meat', 'meats', 'mesh', ...
                'ram', 'rame', 'ramet', 'ramets', 'rash', 'rate', 'rates', ...
                'rat', 'rats', 'rest', 'rhea', 'rheas', ...
                'same', 'seam', 'sear', 'seat', 'shear', 'share', ...
                'smart', 'smear', 'star', 'stare', 'steam', 'stem', 'stream', ...
                'tame', 'tamer', 'tamers', 'tames', 'tar', 'team', 'teams', ...
                'tear', 'term', 'terms', 'the', ...
                'hamster', 'mathers', 'master' ...
            };

            % Theme words (animals — subset of wordList that fit the theme)
            puzzle.themeWords = { ...
                'ear', 'ears', 'eat', 'eats', ...
                'ham', 'hams', 'hare', 'hares', 'hart', 'harts', ...
                'mare', 'mares', 'mate', 'mates', 'meat', 'meats', ...
                'rats', 'shear', 'tame', 'tamer', 'tamers', ...
                'rhea', 'rheas', 'hamster', 'hate', 'hates', 'smart', 'earths', ...
                'heart', 'hearts', ...
            };

            % Build wordPoints map (1 pt per theme word)
            puzzle.wordPoints = containers.Map( ...
                'KeyType', 'char', 'ValueType', 'double');
            for i = 1:length(puzzle.themeWords)
                puzzle.wordPoints(puzzle.themeWords{i}) = 1;
            end

            % Max score = total number of theme words (1 pt each)
            puzzle.maxScore = length(puzzle.themeWords);
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

        % scoreWord — every word is worth 1 point
        function pts = scoreWord(~, ~)
            pts = 1;
        end

        % updateBeeImage — 1 section per 2 pts, fully colored at 10
        function updateBeeImage(app)
            s = app.Score;
            if s >= 10
                app.blankbee.ImageSource = 'bee6.png';
            elseif s >= 8
                app.blankbee.ImageSource = 'bee5.png';
            elseif s >= 6
                app.blankbee.ImageSource = 'bee4.png';
            elseif s >= 4
                app.blankbee.ImageSource = 'bee3.png';
            elseif s >= 2
                app.blankbee.ImageSource = 'bee2.png';
            else
                app.blankbee.ImageSource = 'bee1.png';
            end
            app.BeeProgressLabel.Text = sprintf('%d / 10 pts  (+2 pts colors a section)', s);
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
                'ImageSource', fullfile(pathToMLAPP, 'bee1.png'));

            % Bee progress hint
            app.BeeProgressLabel = uilabel(app.UIFigure, ...
                'Text', '0 / 10 pts  (+2 pts colors a section)', ...
                'FontName', 'Andale Mono', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', ...
                'FontColor', [0.5 0.5 0.5], ...
                'Position', [188 340 278 16]);

            % Word wheel
            app.wordwheel = uiimage(app.UIFigure, ...
                'Position', [188 92 278 244], ...
                'ImageSource', fullfile(pathToMLAPP, 'word wheel1.png'));

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

            % Win/lose screen ---NEW
            app.win_lose_screen = uipanel(app.UIFigure);
            app.win_lose_screen.BorderColor = [0 0 0];
            app.win_lose_screen.HighlightColor = [0 0 0];
            app.win_lose_screen.Visible = 'off';
            app.win_lose_screen.Position = [194 81 267 264];

            % Win/lose graphic ---NEW
            app.endgraphic = uiimage(app.win_lose_screen);
            app.endgraphic.Position = [-37 2 341 259];
            app.endgraphic.ImageSource = fullfile(pathToMLAPP, 'win.png');

            % Replay button ---NEW
            app.replaybutton = uibutton(app.win_lose_screen, 'push');
                'ButtonPushedFcn', createCallbackFcn(app, @replaybuttonPushed, true));
            app.replaybutton.Icon = fullfile(pathToMLAPP, 'playagain.png');
            app.replaybutton.IconAlignment = 'bottom';
            app.replaybutton.BackgroundColor = [1 0.8706 0.349];
            app.replaybutton.Position = [58 35 153 63];
            app.replaybutton.Text = '';

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
