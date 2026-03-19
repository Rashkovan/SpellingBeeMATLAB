classdef spelling_bee_ui_draft < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        shufflebutton        matlab.ui.control.Button
        strikecounter        matlab.ui.control.Label
        STRIKESLabel         matlab.ui.control.Label
        wordwheel            matlab.ui.control.Image
        WordsListBox         matlab.ui.control.ListBox
        WordsFoundLabel      matlab.ui.control.Label
        blankbee             matlab.ui.control.Image
        scorecounter         matlab.ui.control.Label
        AnimalsLabel         matlab.ui.control.Label
        THEMELabel           matlab.ui.control.Label
        SCORELabel           matlab.ui.control.Label
        inputfield           matlab.ui.control.EditField
        GUESSEditFieldLabel  matlab.ui.control.Label
        win_lose_screen      matlab.ui.container.Panel
        replaybutton         matlab.ui.control.Button
        endgraphic           matlab.ui.control.Image %NEW - graphics for win/lose and replay button
    end

%perhaps edit this? this initializes variables not sure if already done in code    
    properties (Access = private)
        Score = 0; % Description
        Penalties = 0;
        FoundWords = {};
    end

    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            %STARTUP, initialize score and penalties at 0

            app.scorecounter.Text = num2str(app.Score);
            app.strikecounter.Text = num2str(app.Penalties);
            app.win_lose_screen.Visible = 'off'; % --- NEW: Hide the game over screen at start

            %will need to also add the same code whenever a penalty or
            %point is added to update the image

            %set word box as empty:
            app.WordsListBox.Items = {}; 

        end

        % Value changed function: inputfield
        function inputfieldValueChanged(app, event)
%WORD INPUT FIELD: (changing inputted word to uppercase!)
            userGuess = upper(app.inputfield.Value);

%PUT WORD VALIDATION BELOW! THIS IS PLACEHOLDER CODE!
%Will need to update function to fit into this

    if isempty(userGuess) || ismember(userGuess, app.FoundWords)
        app.inputfield.Value = '';
        return;
    end
    %FOUND WORD BOX UPDATING WILL GO HERE (after code is inputted)

    %BEE IMAGE UPDATER:
    if app.Score >= 10 %win = fully colored bee
        app.blankbee.ImageSource = 'bee6.png';

    elseif app.Score == 8 || app.Score == 9 %8-9 points
        app.blankbee.ImageSource = 'bee5.png';

    elseif app.Score == 6 || app.Score == 7 %6-7 points
        app.blankbee.ImageSource = 'bee4.png';

    elseif app.Score == 4 || app.Score == 5 %4-5 points
        app.blankbee.ImageSource = 'bee3.png';

    elseif app.Score == 2 || app.Score == 3 %2-3 points
        app.blankbee.ImageSource = 'bee2.png';

    else %0-1 points: clear bee
        app.blankbee.ImageSource = 'bee1.png';
    end


            
        end

        % Button pushed function: shufflebutton
        function shufflebuttonButtonPushed(app, event)
          %SHUFFLE BUTTON CODE:
          %randomly pick a new shuffled image: 
          %(might add specs so it doesn't show the same img twice)

          imgNum = randi([1 , 7]);
          app.wordwheel.ImageSource = sprintf('word wheel%d.png', imgNum);


        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create GUESSEditFieldLabel
            app.GUESSEditFieldLabel = uilabel(app.UIFigure);
            app.GUESSEditFieldLabel.HorizontalAlignment = 'right';
            app.GUESSEditFieldLabel.FontName = 'Andale Mono';
            app.GUESSEditFieldLabel.FontSize = 24;
            app.GUESSEditFieldLabel.Position = [224 35 91 32];
            app.GUESSEditFieldLabel.Text = 'GUESS:';

            % Create inputfield
            app.inputfield = uieditfield(app.UIFigure, 'text');
            app.inputfield.ValueChangedFcn = createCallbackFcn(app, @inputfieldValueChanged, true);
            app.inputfield.FontSize = 24;
            app.inputfield.Position = [330 32 100 35];

            % Create SCORELabel
            app.SCORELabel = uilabel(app.UIFigure);
            app.SCORELabel.FontName = 'Andale Mono';
            app.SCORELabel.FontSize = 24;
            app.SCORELabel.Position = [44 396 91 32];
            app.SCORELabel.Text = 'SCORE:';

            % Create THEMELabel
            app.THEMELabel = uilabel(app.UIFigure);
            app.THEMELabel.FontName = 'Andale Mono';
            app.THEMELabel.FontSize = 24;
            app.THEMELabel.FontColor = [0.149 0.149 0.149];
            app.THEMELabel.Position = [44 360 91 32];
            app.THEMELabel.Text = 'THEME:';

            % Create AnimalsLabel
            app.AnimalsLabel = uilabel(app.UIFigure);
            app.AnimalsLabel.FontName = 'Andale Mono';
            app.AnimalsLabel.FontSize = 24;
            app.AnimalsLabel.FontColor = [0.9294 0.6941 0.1255];
            app.AnimalsLabel.Position = [136 360 106 32];
            app.AnimalsLabel.Text = 'Animals';

            % Create scorecounter
            app.scorecounter = uilabel(app.UIFigure);
            app.scorecounter.FontName = 'Andale Mono';
            app.scorecounter.FontSize = 24;
            app.scorecounter.Position = [134 396 106 32];
            app.scorecounter.Text = '(Score)';

            % Create blankbee
            app.blankbee = uiimage(app.UIFigure);
            app.blankbee.Position = [263 344 116 118];
            app.blankbee.ImageSource = fullfile(pathToMLAPP, 'spelling bee clear.png');

            % Create WordsFoundLabel
            app.WordsFoundLabel = uilabel(app.UIFigure);
            app.WordsFoundLabel.HorizontalAlignment = 'right';
            app.WordsFoundLabel.FontName = 'Andale Mono';
            app.WordsFoundLabel.FontSize = 18;
            app.WordsFoundLabel.Position = [465 355 70 24];
            app.WordsFoundLabel.Text = 'Words:';

            % Create WordsListBox
            app.WordsListBox = uilistbox(app.UIFigure);
            app.WordsListBox.FontName = 'Andale Mono';
            app.WordsListBox.FontSize = 14;
            app.WordsListBox.Position = [550 220 79 161];

            % Create wordwheel
            app.wordwheel = uiimage(app.UIFigure);
            app.wordwheel.Position = [188 92 278 244];
            app.wordwheel.ImageSource = fullfile(pathToMLAPP, 'word wheel.png');

            % Create STRIKESLabel
            app.STRIKESLabel = uilabel(app.UIFigure);
            app.STRIKESLabel.FontName = 'Andale Mono';
            app.STRIKESLabel.FontSize = 24;
            app.STRIKESLabel.Position = [448 396 120 32];
            app.STRIKESLabel.Text = 'STRIKES:';

            % Create strikecounter
            app.strikecounter = uilabel(app.UIFigure);
            app.strikecounter.FontName = 'Andale Mono';
            app.strikecounter.FontSize = 24;
            app.strikecounter.Position = [567 396 48 32];
            app.strikecounter.Text = '(X)';

            % Create shufflebutton
            app.shufflebutton = uibutton(app.UIFigure, 'push');
            app.shufflebutton.ButtonPushedFcn = createCallbackFcn(app, @shufflebuttonButtonPushed, true);
            app.shufflebutton.Icon = fullfile(pathToMLAPP, 'shuffle button.png');
            app.shufflebutton.Position = [145 21 63 57];
            app.shufflebutton.Text = '';

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
            app.replaybutton.Icon = fullfile(pathToMLAPP, 'playagain.png');
            app.replaybutton.IconAlignment = 'bottom';
            app.replaybutton.BackgroundColor = [1 0.8706 0.349];
            app.replaybutton.Position = [58 35 153 63];
            app.replaybutton.Text = '';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = spelling_bee_ui_draft

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
