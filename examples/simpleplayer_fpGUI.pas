program simpleplayer_fpGUI;

{$mode objfpc}{$H+}
  {$DEFINE UseCThreads}

uses
  {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads,
  cwstring, {$ENDIF} {$ENDIF}
  SysUtils,
  uos_flat,
  ctypes, 
  //Math,
  Classes,
  fpg_button,
  fpg_widget,
  fpg_label,
  fpg_Editbtn,
  fpg_RadioButton,
  fpg_trackbar,
  fpg_CheckBox,
  fpg_Panel,
  fpg_base,
  fpg_main,
  fpg_form { you can add units after this };

type
  TSimpleplayer = class(TfpgForm)
    procedure uos_logo(Sender: TObject);
  private
    {@VFD_HEAD_BEGIN: Simpleplayer}
    Custom1: TfpgWidget;
    Labelport: TfpgLabel;
    btnLoad: TfpgButton;
    FilenameEdit1: TfpgFileNameEdit;
    FilenameEdit2: TfpgFileNameEdit;
    FilenameEdit4: TfpgFileNameEdit;
    btnStart: TfpgButton;
    btnStop: TfpgButton;
    lposition: TfpgLabel;
    Labelsnf: TfpgLabel;
    Labelmpg: TfpgLabel;
    Labelst: TfpgLabel;
    FilenameEdit3: TfpgFileNameEdit;
    FilenameEdit5: TfpgFileNameEdit;
    Label1: TfpgLabel;
    Llength: TfpgLabel;
    btnpause: TfpgButton;
    btnresume: TfpgButton;
    CheckBox1: TfpgCheckBox;
    RadioButton1: TfpgRadioButton;
    RadioButton2: TfpgRadioButton;
    RadioButton3: TfpgRadioButton;
    Label2: TfpgLabel;
    TrackBar1: TfpgTrackBar;
    TrackBar2: TfpgTrackBar;
    TrackBar3: TfpgTrackBar;
    Label3: TfpgLabel;
    Label4: TfpgLabel;
    Label5: TfpgLabel;
    vuleft: TfpgPanel;
    vuright: TfpgPanel;
    CheckBox2: TfpgCheckBox;
    Label6: TfpgLabel;
    Label7: TfpgLabel;
    TrackBar4: TfpgTrackBar;
    TrackBar5: TfpgTrackBar;
    Button1: TfpgButton;
    chkst2b: TfpgCheckBox;
    chknoise: TfpgCheckBox;
    Labelst1: TfpgLabel;
    FilenameEdit6: TfpgFileNameEdit;
    {@VFD_HEAD_END: Simpleplayer}
  public
    procedure AfterCreate; override;
    // constructor Create(AOwner: TComponent);
    procedure btnLoadClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnResumeClick(Sender: TObject);
    procedure btnTrackOnClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; const pos: TPoint);
    procedure btnTrackOffClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; const pos: TPoint);
     {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
          {$else}
    procedure CustomMsgReceived(var msg: TfpgMessageRec); message MSG_CUSTOM1;
      {$ENDIF}
    procedure ClosePlayer1;
    procedure LoopProcPlayer1;
    procedure ShowPosition;
    procedure ShowLevel;
    procedure changecheck(Sender: TObject);
    procedure VolumeChange(Sender: TObject; pos: integer);
    procedure ChangeNoise(Sender: TObject);
    procedure ChangePlugSetSoundTouch(Sender: TObject);
    procedure ChangePlugSetbs2b(Sender: TObject);
    procedure TrackChangePlugSetSoundTouch(Sender: TObject; pos: integer);
    procedure ResetPlugClick(Sender: TObject);
  end;

  {@VFD_NEWFORM_DECL}

  {@VFD_NEWFORM_IMPL}

var
  PlayerIndex1: integer;
  ordir, opath: string;
  OutputIndex1, InputIndex1, DSPIndex1, PluginIndex1, PluginIndex2: integer;
  plugsoundtouch : boolean = false;
  plugbs2b : boolean = false;
 
  procedure TSimpleplayer.btnTrackOnClick(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; const pos: TPoint);
  begin
    TrackBar1.Tag := 1;
   end;
   
   procedure TSimpleplayer.ChangePlugSetBs2b(Sender: TObject);
   begin
  uos_SetPluginBs2b(PlayerIndex1, PluginIndex1, -1, -1, -1, chkst2b.Checked);   
  end;
  
  procedure TSimpleplayer.ChangeNoise(Sender: TObject);
   begin
   uos_SetDSPNoiseRemovalIn(PlayerIndex1, PluginIndex1, -1, -1, -1, -1, chknoise.Checked);   
  end;

  procedure TSimpleplayer.ChangePlugSetSoundTouch(Sender: TObject);
  var
    tempo, rate: cfloat;
  begin
         if (trim(Pchar(filenameedit5.FileName)) <> '') and fileexists(filenameedit5.FileName) then
  begin
    if 2 - (2 * (TrackBar4.Position / 100)) < 0.3 then
      tempo := 0.3
    else
      tempo := 2 - (2 * (TrackBar4.Position / 100));
    if 2 - (2 * (TrackBar5.Position / 100)) < 0.3 then
      rate := 0.3
    else
      rate := 2 - (2 * (TrackBar5.Position / 100));

    label6.Text := 'Tempo: ' + floattostrf(tempo, ffFixed, 15, 1);
    label7.Text := 'Pitch: ' + floattostrf(rate, ffFixed, 15, 1);

    if radiobutton1.Enabled = False then   /// player1 was created
    begin
      uos_SetPluginSoundTouch(PlayerIndex1, PluginIndex2, tempo, rate, checkbox2.Checked);
    end;
    end;
  end;

  procedure TSimpleplayer.ResetPlugClick(Sender: TObject);
  begin
    TrackBar4.Position := 50;
    TrackBar5.Position := 50;
    if radiobutton1.Enabled = False then   /// player1 was created
    begin
      uos_SetPluginSoundTouch(PlayerIndex1, PluginIndex2, 1, 1, checkbox2.Checked);
    end;
  end;

  procedure TSimpleplayer.TrackChangePlugSetSoundTouch(Sender: TObject; pos: integer);
  begin
       if (trim(Pchar(filenameedit5.FileName)) <> '') and fileexists(filenameedit5.FileName) then
      ChangePlugSetSoundTouch(Sender);
  end;

  procedure TSimpleplayer.btnTrackoffClick(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; const pos: TPoint);
  begin
    uos_Seek(PlayerIndex1, InputIndex1, TrackBar1.position);
    TrackBar1.Tag := 0;
  end;

  procedure TSimpleplayer.btnResumeClick(Sender: TObject);
  begin
    uos_RePlay(PlayerIndex1);
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := True;
    btnresume.Enabled := False;
  end;

  procedure TSimpleplayer.btnPauseClick(Sender: TObject);
  begin
    uos_Pause(PlayerIndex1);
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := False;
    btnresume.Enabled := True;
    vuLeft.Visible := False;
    vuRight.Visible := False;
    vuright.Height := 0;
    vuleft.Height := 0;
    vuright.UpdateWindowPosition;
    vuLeft.UpdateWindowPosition;
  end;

  procedure TSimpleplayer.changecheck(Sender: TObject);
  begin
    if (btnstart.Enabled = False) then
      uos_SetDSPIn(PlayerIndex1, InputIndex1, DSPIndex1, checkbox1.Checked);
  end;

  procedure TSimpleplayer.VolumeChange(Sender: TObject; pos: integer);
  begin
    if (btnstart.Enabled = False) then
      uos_SetDSPVolumeIn(PlayerIndex1, InputIndex1,
        (100 - TrackBar2.position) / 100,
        (100 - TrackBar3.position) / 100, True);
  end;

 procedure TSimpleplayer.ShowLevel;
  begin
    vuLeft.Visible := True;
    vuRight.Visible := True;
    if round(uos_InputGetLevelLeft(PlayerIndex1, InputIndex1) * 128) >= 0 then
      vuLeft.Height := round(uos_InputGetLevelLeft(PlayerIndex1, InputIndex1) * 128);
    if round(uos_InputGetLevelRight(PlayerIndex1, InputIndex1) * 128) >= 0 then
      vuRight.Height := round(uos_InputGetLevelRight(PlayerIndex1, InputIndex1) * 128);
    vuLeft.top := 380 - vuLeft.Height;
    vuRight.top := 380 - vuRight.Height;
    vuright.UpdateWindowPosition;
    vuLeft.UpdateWindowPosition;
  end;

  procedure TSimpleplayer.btnCloseClick(Sender: TObject);
  begin
    if (btnstart.Enabled = False) then
    begin
      uos_stop(PlayerIndex1);
      vuLeft.Visible := False;
      vuRight.Visible := False;
      vuright.Height := 0;
      vuleft.Height := 0;
      vuright.UpdateWindowPosition;
      vuLeft.UpdateWindowPosition;
      sleep(100);
    end;
    if btnLoad.Enabled = False then
    begin
      uos_UnloadPlugin('soundtouch');
      uos_UnloadPlugin('bs2b');
      uos_UnloadLib();
    end;  
  end;

  procedure TSimpleplayer.btnLoadClick(Sender: TObject);
var
loadok : boolean = false;
  begin
    // Load the libraries
    // function uos_LoadLib(PortAudioFileName: Pchar; SndFileFileName: Pchar;
    // Mpg123FileName: Pchar: Pchar) : integer;
if uos_LoadLib(Pchar(FilenameEdit1.FileName), Pchar(FilenameEdit2.FileName),
 Pchar(FilenameEdit3.FileName)) = 0 then
    begin
      hide;
      loadok := true;
      Height := 435;
      btnStart.Enabled := True;
      btnLoad.Enabled := False;
      FilenameEdit1.ReadOnly := True;
      FilenameEdit2.ReadOnly := True;
      FilenameEdit3.ReadOnly := True;
      FilenameEdit5.ReadOnly := True;
      FilenameEdit6.ReadOnly := True;
      UpdateWindowPosition;
       btnLoad.Text :=
        'PortAudio, SndFile, Mpg123 libraries are loaded...'
       end else btnLoad.Text :=
        'One or more libraries did not load, check filenames...';
        
        if loadok = true then
        begin
           if ((trim(Pchar(filenameedit5.FileName)) <> '') and fileexists(filenameedit5.FileName))
       then if (uos_LoadPlugin('soundtouch', Pchar(FilenameEdit5.FileName)) = 0)  then
       begin
      plugsoundtouch := true;
          btnLoad.Text :=
        'PortAudio, SndFile, Mpg123 and Plugin are loaded...';
        end
         else
         begin
        TrackBar4.enabled := false;
       TrackBar5.enabled := false;
       CheckBox2.enabled := false;
       Button1.enabled := false;
       label6.enabled := false;
       label7.enabled := false;
           end;    
          
      if ((trim(Pchar(filenameedit6.FileName)) <> '') and fileexists(filenameedit6.FileName)) 
      then if (uos_LoadPlugin('bs2b', Pchar(FilenameEdit6.FileName)) = 0)
      then plugbs2b := true else chkst2b.enabled := false; 
          
      WindowPosition := wpScreenCenter;
      WindowTitle := 'Simple Player.    uos Version ' + inttostr(uos_getversion());
       fpgapplication.ProcessMessages;
      sleep(500);
      Show;
    end;
  end;

  procedure TSimpleplayer.ClosePlayer1;
  begin
    radiobutton1.Enabled := True;
    radiobutton2.Enabled := True;
    radiobutton3.Enabled := True;
    vuLeft.Visible := False;
    vuRight.Visible := False;
    vuright.Height := 0;
    vuleft.Height := 0;
    vuright.UpdateWindowPosition;
    vuLeft.UpdateWindowPosition;
    btnStart.Enabled := True;
    btnStop.Enabled := False;
    btnPause.Enabled := False;
    btnresume.Enabled := False;
    trackbar1.Position := 0;
    lposition.Text := '00:00:00.000';
  end;

  procedure TSimpleplayer.btnStopClick(Sender: TObject);
  begin
    uos_Stop(PlayerIndex1);
    closeplayer1;
  end;

  function DSPReverseBefore(Data: TuosF_Data; fft: TuosF_FFT): TDArFloat;
  begin
    if Data.position > Data.OutFrames div Data.ratio then
      uos_Seek(PlayerIndex1, InputIndex1, Data.position - 2 - (Data.OutFrames div Data.Ratio));
  end;

  function DSPReverseAfter(Data: TuosF_Data; fft: TuosF_FFT): TDArFloat;
  var
    x: integer = 0;
    arfl: TDArFloat;

  begin
    SetLength(arfl, length(Data.Buffer));
       while x < length(Data.Buffer) + 1 do
          begin
      arfl[x] := Data.Buffer[length(Data.Buffer) - x - 1] ;
      arfl[x+1] := Data.Buffer[length(Data.Buffer) - x ]  ;
         x := x +2;
          end;

    Result := arfl;
  end;
  
  /// WARNING: This is only to show a DSP effect, it is not the best reverb it exists ;-)
  function DSPReverb(Data: TuosF_Data; fft: TuosF_FFT): TDArFloat;
  var
    x: integer = 0;
    arfl: TDArFloat;
  begin
    SetLength(arfl, length(Data.Buffer));
         while x < length(Data.Buffer)   do
          begin
      if x > 10000 then
      begin
        arfl[x] := Data.Buffer[x] + (Data.Buffer[x-10000] / 2);
        arfl[x+1] := Data.Buffer[x+1] + (Data.Buffer[x+1-10000] / 2);
      end else 
     begin
        arfl[x] := Data.Buffer[x] ;
        arfl[x+1] := Data.Buffer[x+1];
      end;
       x := x + 2;
          end;
       Result := arfl;
  end;


  procedure TSimpleplayer.btnStartClick(Sender: TObject);
  var
    samformat: shortint;
    temptime: ttime;
    ho, mi, se, ms: word;
  begin

    if radiobutton1.Checked = True then
      samformat := 0;
    if radiobutton2.Checked = True then
      samformat := 1;
    if radiobutton3.Checked = True then
      samformat := 2;

    radiobutton1.Enabled := False;
    radiobutton2.Enabled := False;
    radiobutton3.Enabled := False;

    PlayerIndex1 := 0;
    // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
    // If PlayerIndex exists already, it will be overwritten...

    {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
     uos_CreatePlayer(PlayerIndex1);
     {$else}
    uos_CreatePlayer(PlayerIndex1,self);
    {$endif}
    //// Create the player.
    //// PlayerIndex : from 0 to what your computer can do !
    //// If PlayerIndex exists already, it will be overwriten...

     InputIndex1 := uos_AddFromFile(PlayerIndex1, pchar(filenameEdit4.filename), -1, 
     samformat, -1);
    //// add input from audio file with custom parameters
    ////////// FileName : filename of audio file
    //////////// PlayerIndex : Index of a existing Player
    ////////// OutputIndex : OutputIndex of existing Output // -1 : all output, -2: no output, other integer : existing output)
    ////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16) SampleFormat of Input can be <= SampleFormat float of Output
    //////////// FramesCount : default : -1 (65536 div channels)
    //  result : -1 nothing created, otherwise Input Index in array

    if InputIndex1 > -1 then begin

      // OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1) ;
    //// add a Output into device with default parameters
    OutputIndex1 := uos_AddIntoDevOut(PlayerIndex1, -1, -1, uos_InputGetSampleRate(PlayerIndex1, InputIndex1),
     uos_InputGetChannels(PlayerIndex1, InputIndex1), samformat, -1);
    //// add a Output into device with custom parameters
    //////////// PlayerIndex : Index of a existing Player
    //////////// Device ( -1 is default Output device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)   /// here default samplerate of input
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (65536)
    //  result : -1 nothing created, otherwise Output Index in array

    uos_InputSetLevelEnable(PlayerIndex1, InputIndex1, 2) ;
     ///// set calculation of level/volume (usefull for showvolume procedure)
                       ///////// set level calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul before all DSP procedures.
                          // 2 => calcul after all DSP procedures.
                          // 3 => calcul before and after all DSP procedures.

    uos_InputSetPositionEnable(PlayerIndex1, InputIndex1, 1) ;
     ///// set calculation of position (usefull for positions procedure)
                       ///////// set position calculation (default is 0)
                          // 0 => no calcul
                          // 1 => calcul position.

    uos_LoopProcIn(PlayerIndex1, InputIndex1, @LoopProcPlayer1);
    ///// Assign the procedure of object to execute inside the loop
    //////////// PlayerIndex : Index of a existing Player
    //////////// InputIndex1 : Index of a existing Input
    //////////// LoopProcPlayer1 : procedure of object to execute inside the loop
   
     uos_AddDSPNoiseRemovalIn(PlayerIndex1, InputIndex1);
     uos_SetDSPNoiseRemovalIn(PlayerIndex1, InputIndex1, -1, -1, -1, -1, chknoise.Checked);
     /// Add DSP Noise removal. First chunck will be the noise sample.
   
     uos_AddDSPVolumeIn(PlayerIndex1, InputIndex1, 1, 1);
    ///// DSP Volume changer
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// InputIndex1 : Index of a existing input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume

     uos_SetDSPVolumeIn(PlayerIndex1, InputIndex1,
      (100 - TrackBar2.position) / 100,
      (100 - TrackBar3.position) / 100, True);
    /// Set volume
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// InputIndex1 : InputIndex of a existing Input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled
  
   // This is a custom reverb... but not the best... only to show how to do a DSP ;-) 
  // {
  // DSPIndex2 := uos_AddDSPIn(PlayerIndex1, InputIndex1, nil, @DSPReverb, nil, nil);
  // uos_SetDSPIn(PlayerIndex1, InputIndex1, DSPIndex2, true);
  // }
  
   DSPIndex1 := uos_AddDSPIn(PlayerIndex1, InputIndex1, @DSPReverseBefore,
     @DSPReverseAfter, nil, nil);
      ///// add a custom DSP procedure for input
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// InputIndex1: InputIndex of existing input
    ////////// BeforeFunc : function to do before the buffer is filled
    ////////// AfterFunc : function to do after the buffer is filled
    ////////// EndedFunc : function to do at end of thread
    ////////// LoopProc : external procedure to do after the buffer is filled
   
   //// set the parameters of custom DSP;
   uos_SetDSPIn(PlayerIndex1, InputIndex1, DSPIndex1, checkbox1.Checked);
   
  ///// add bs2b plugin with samplerate_of_input1 / default channels (2 = stereo)
  if plugbs2b = true then
  begin
   PlugInIndex1 := uos_AddPlugin(PlayerIndex1, 'bs2b',
   uos_InputGetSampleRate(PlayerIndex1, InputIndex1) , -1);
   uos_SetPluginbs2b(PlayerIndex1, PluginIndex1, -1 , -1, -1, chkst2b.checked);
  end; 
  
  /// add SoundTouch plugin with samplerate of input1 / default channels (2 = stereo)
  /// SoundTouch plugin should be the last added.
    if plugsoundtouch = true then
  begin
    PlugInIndex2 := uos_AddPlugin(PlayerIndex1, 'soundtouch', 
    uos_InputGetSampleRate(PlayerIndex1, InputIndex1) , -1);
    ChangePlugSetSoundTouch(self); //// custom procedure to Change plugin settings
   end;    
         
   trackbar1.Max := uos_InputLength(PlayerIndex1, InputIndex1);
    ////// Length of Input in samples

   temptime := uos_InputLengthTime(PlayerIndex1, InputIndex1);
    ////// Length of input in time

    DecodeTime(temptime, ho, mi, se, ms);
    
    llength.Text := format('%d:%d:%d.%d', [ho, mi, se, ms]);

    /////// procedure to execute when stream is terminated
    uos_EndProc(PlayerIndex1, @ClosePlayer1);
    ///// Assign the procedure of object to execute at end
    //////////// PlayerIndex : Index of a existing Player
    //////////// ClosePlayer1 : procedure of object to execute inside the general loop

    TrackBar1.position := 0;
    trackbar1.Enabled := True;
    CheckBox1.Enabled := True;

    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnpause.Enabled := True;
    btnresume.Enabled := False;

    uos_Play(PlayerIndex1);  /////// everything is ready, here we are, lets play it...
    end;
  end;

  procedure TSimpleplayer.ShowPosition;
  var
    temptime: ttime;
    ho, mi, se, ms: word;
  begin
    if (TrackBar1.Tag = 0) then
    begin
      if uos_InputPosition(PlayerIndex1, InputIndex1) > 0 then
      begin
        TrackBar1.Position := uos_InputPosition(PlayerIndex1, InputIndex1);
        temptime := uos_InputPositionTime(PlayerIndex1, InputIndex1);
        ////// Length of input in time
        DecodeTime(temptime, ho, mi, se, ms);
        lposition.Text := format('%.2d:%.2d:%.2d.%.3d', [ho, mi, se, ms]);
      end;
    end;
  end;

   {$IF (FPC_FULLVERSION >= 20701) or DEFINED(Windows)}
      {$else}
  procedure TSimpleplayer.CustomMsgReceived(var msg: TfpgMessageRec);
  begin
    ShowLevel;
    ShowPosition ;
    end;

      {$ENDIF}

procedure TSimpleplayer.LoopProcPlayer1;
begin
 ShowPosition;
 ShowLevel ;
end;

  procedure TSimpleplayer.AfterCreate;
  begin
    {%region 'Auto-generated GUI code' -fold}

    {@VFD_BODY_BEGIN: Simpleplayer}
  Name := 'Simpleplayer';
  SetPosition(571, 86, 503, 455);
  WindowTitle := 'Simple player ';
  IconName := '';
  BackGroundColor := $80000001;
  Hint := '';
  WindowPosition := wpScreenCenter;
  Ondestroy := @btnCloseClick;

  Custom1 := TfpgWidget.Create(self);
  with Custom1 do
  begin
    Name := 'Custom1';
    SetPosition(10, 4, 115, 195);
    OnPaint := @uos_logo;
  end;

  Labelport := TfpgLabel.Create(self);
  with Labelport do
  begin
    Name := 'Labelport';
    SetPosition(136, 0, 320, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Folder + filename of PortAudio Library';
    Hint := '';
  end;

  btnLoad := TfpgButton.Create(self);
  with btnLoad do
  begin
    Name := 'btnLoad';
    SetPosition(8, 204, 488, 23);
    Text := 'Load that libraries';
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 0;
    Hint := '';
    onclick := @btnLoadClick;
  end;

  FilenameEdit1 := TfpgFileNameEdit.Create(self);
  with FilenameEdit1 do
  begin
    Name := 'FilenameEdit1';
    SetPosition(136, 16, 356, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 3;
  end;

  FilenameEdit2 := TfpgFileNameEdit.Create(self);
  with FilenameEdit2 do
  begin
    Name := 'FilenameEdit2';
    SetPosition(136, 56, 356, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 4;
  end;

  FilenameEdit4 := TfpgFileNameEdit.Create(self);
  with FilenameEdit4 do
  begin
    Name := 'FilenameEdit4';
    SetPosition(132, 236, 360, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 5;
  end;

  btnStart := TfpgButton.Create(self);
  with btnStart do
  begin
    Name := 'btnStart';
    SetPosition(140, 408, 44, 23);
    Text := 'Play';
    Enabled := False;
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 6;
    Hint := '';
    onclick := @btnstartClick;
  end;

  btnStop := TfpgButton.Create(self);
  with btnStop do
  begin
    Name := 'btnStop';
    SetPosition(364, 408, 80, 23);
    Text := 'Stop';
    Enabled := False;
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 7;
    Hint := '';
    onclick := @btnStopClick;
  end;

  lposition := TfpgLabel.Create(self);
  with lposition do
  begin
    Name := 'lposition';
    SetPosition(228, 297, 84, 19);
    Alignment := taCenter;
    FontDesc := '#Label2';
    ParentShowHint := False;
    Text := '00:00:00.000';
    Hint := '';
  end;

  Labelsnf := TfpgLabel.Create(self);
  with Labelsnf do
  begin
    Name := 'Labelsnf';
    SetPosition(140, 40, 316, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Folder + filename of SndFile Library';
    Hint := '';
  end;

  Labelmpg := TfpgLabel.Create(self);
  with Labelmpg do
  begin
    Name := 'Labelmpg';
    SetPosition(136, 80, 316, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Folder + filename of Mpg123 Library';
    Hint := '';
  end;

  Labelst := TfpgLabel.Create(self);
  with Labelst do
  begin
    Name := 'Labelst';
    SetPosition(136, 120, 316, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Folder + filename of SoundTouch Library';
    Hint := '';
  end;

  FilenameEdit3 := TfpgFileNameEdit.Create(self);
  with FilenameEdit3 do
  begin
    Name := 'FilenameEdit3';
    SetPosition(136, 96, 356, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 12;
  end;

  FilenameEdit5 := TfpgFileNameEdit.Create(self);
  with FilenameEdit5 do
  begin
    Name := 'FilenameEdit5';
    SetPosition(136, 136, 356, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 12;
  end;

  Label1 := TfpgLabel.Create(self);
  with Label1 do
  begin
    Name := 'Label1';
    SetPosition(312, 297, 12, 15);
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := '/';
    Hint := '';
  end;

  Llength := TfpgLabel.Create(self);
  with Llength do
  begin
    Name := 'Llength';
    SetPosition(320, 297, 80, 15);
    FontDesc := '#Label2';
    ParentShowHint := False;
    Text := '00:00:00.000';
    Hint := '';
  end;

  btnpause := TfpgButton.Create(self);
  with btnpause do
  begin
    Name := 'btnpause';
    SetPosition(204, 408, 52, 23);
    Text := 'Pause';
    Enabled := False;
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 15;
    Hint := '';
    onclick := @btnPauseClick;
  end;

  btnresume := TfpgButton.Create(self);
  with btnresume do
  begin
    Name := 'btnresume';
    SetPosition(276, 408, 64, 23);
    Text := 'Resume';
    Enabled := False;
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 16;
    Hint := '';
    onclick := @btnResumeClick;
  end;

  CheckBox1 := TfpgCheckBox.Create(self);
  with CheckBox1 do
  begin
    Name := 'CheckBox1';
    SetPosition(16, 404, 104, 19);
    FontDesc := '#Label1';
    ParentShowHint := False;
    TabOrder := 17;
    Text := 'Play Reverse';
    Hint := '';
  end;

  RadioButton1 := TfpgRadioButton.Create(self);
  with RadioButton1 do
  begin
    Name := 'RadioButton1';
    SetPosition(112, 312, 96, 19);
    Checked := True;
    FontDesc := '#Label1';
    GroupIndex := 0;
    ParentShowHint := False;
    TabOrder := 18;
    Text := 'Float 32 bit';
    Hint := '';
  end;

  RadioButton2 := TfpgRadioButton.Create(self);
  with RadioButton2 do
  begin
    Name := 'RadioButton2';
    SetPosition(112, 328, 100, 19);
    FontDesc := '#Label1';
    GroupIndex := 0;
    ParentShowHint := False;
    TabOrder := 19;
    Text := 'Int 32 bit';
    Hint := '';
  end;

  RadioButton3 := TfpgRadioButton.Create(self);
  with RadioButton3 do
  begin
    Name := 'RadioButton3';
    SetPosition(112, 346, 100, 19);
    FontDesc := '#Label1';
    GroupIndex := 0;
    ParentShowHint := False;
    TabOrder := 20;
    Text := 'Int 16 bit';
    Hint := '';
  end;

  Label2 := TfpgLabel.Create(self);
  with Label2 do
  begin
    Name := 'Label2';
    SetPosition(108, 296, 104, 15);
    FontDesc := '#Label2';
    ParentShowHint := False;
    Text := 'Sample format';
    Hint := '';
  end;

  TrackBar1 := TfpgTrackBar.Create(self);
  with TrackBar1 do
  begin
    Name := 'TrackBar1';
    SetPosition(136, 264, 356, 30);
    ParentShowHint := False;
    TabOrder := 22;
    Hint := '';
    TrackBar1.OnMouseDown := @btntrackonClick;
    TrackBar1.OnMouseUp := @btntrackoffClick;
  end;

  TrackBar2 := TfpgTrackBar.Create(self);
  with TrackBar2 do
  begin
    Name := 'TrackBar2';
    SetPosition(8, 248, 32, 134);
    Orientation := orVertical;
    ParentShowHint := False;
    TabOrder := 23;
    Hint := '';
    OnChange := @volumechange;
  end;

  TrackBar3 := TfpgTrackBar.Create(self);
  with TrackBar3 do
  begin
    Name := 'TrackBar3';
    SetPosition(76, 248, 28, 134);
    Orientation := orVertical;
    ParentShowHint := False;
    TabOrder := 24;
    Hint := '';
    OnChange := @volumechange;
  end;

  Label3 := TfpgLabel.Create(self);
  with Label3 do
  begin
    Name := 'Label3';
    SetPosition(16, 232, 84, 15);
    Alignment := taCenter;
    FontDesc := '#Label2';
    ParentShowHint := False;
    Text := 'Volume';
    Hint := '';
  end;

  Label4 := TfpgLabel.Create(self);
  with Label4 do
  begin
    Name := 'Label4';
    SetPosition(4, 380, 40, 15);
    Alignment := taCenter;
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Left';
    Hint := '';
  end;

  Label5 := TfpgLabel.Create(self);
  with Label5 do
  begin
    Name := 'Label5';
    SetPosition(72, 380, 36, 19);
    Alignment := taCenter;
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Right';
    Hint := '';
  end;

  vuleft := TfpgPanel.Create(self);
  with vuleft do
  begin
    Name := 'vuleft';
    SetPosition(44, 252, 8, 128);
    BackgroundColor := TfpgColor($00D51D);
    FontDesc := '#Label1';
    ParentShowHint := False;
    Style := bsFlat;
    Text := '';
    Hint := '';
  end;

  vuright := TfpgPanel.Create(self);
  with vuright do
  begin
    Name := 'vuright';
    SetPosition(64, 252, 8, 128);
    BackgroundColor := TfpgColor($1DD523);
    FontDesc := '#Label1';
    ParentShowHint := False;
    Style := bsFlat;
    Text := '';
    Hint := '';
  end;

  CheckBox2 := TfpgCheckBox.Create(self);
  with CheckBox2 do
  begin
    Name := 'CheckBox2';
    SetPosition(272, 316, 184, 19);
    FontDesc := '#Label1';
    ParentShowHint := False;
    TabOrder := 32;
    Text := 'Enable SoundTouch PlugIn';
    Hint := 'Change Tempo with same tuning or change Tuning with same tempo';
    OnChange := @ChangePlugSetSoundTouch;
  end;

  Label6 := TfpgLabel.Create(self);
  with Label6 do
  begin
    Name := 'Label6';
    SetPosition(276, 344, 80, 19);
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Tempo: 1.0';
    Hint := '';
  end;

  Label7 := TfpgLabel.Create(self);
  with Label7 do
  begin
    Name := 'Label7';
    SetPosition(384, 344, 80, 15);
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Pitch: 1.0';
    Hint := '';
  end;

  TrackBar4 := TfpgTrackBar.Create(self);
  with TrackBar4 do
  begin
    Name := 'TrackBar4';
    SetPosition(348, 340, 28, 54);
    Orientation := orVertical;
    ParentShowHint := False;
    Position := 50;
    TabOrder := 35;
    Hint := '';
    OnChange := @TrackChangePlugSetSoundTouch;
  end;

  TrackBar5 := TfpgTrackBar.Create(self);
  with TrackBar5 do
  begin
    Name := 'TrackBar5';
    SetPosition(444, 340, 28, 54);
    Orientation := orVertical;
    ParentShowHint := False;
    Position := 50;
    TabOrder := 36;
    Hint := '';
    OnChange := @TrackChangePlugSetSoundTouch;
  end;

  Button1 := TfpgButton.Create(self);
  with Button1 do
  begin
    Name := 'Button1';
    SetPosition(276, 368, 60, 23);
    Text := 'Reset';
    FontDesc := '#Label1';
    ImageName := '';
    ParentShowHint := False;
    TabOrder := 37;
    Hint := '';
    OnClick := @ResetPlugClick;
  end;

  chkst2b := TfpgCheckBox.Create(self);
  with chkst2b do
  begin
    Name := 'chkst2b';
    SetPosition(120, 368, 136, 19);
    FontDesc := '#Label1';
    ParentShowHint := False;
    TabOrder := 38;
    Text := 'Stereo to BinAural';
    Hint := 'Stereo to BinAural (for headphones)';
    OnChange := @ChangePlugSetBs2b;
  end;

  chknoise := TfpgCheckBox.Create(self);
  with chknoise do
  begin
    Name := 'chknoise';
    SetPosition(120, 384, 136, 19);
    FontDesc := '#Label1';
    ParentShowHint := False;
    TabOrder := 38;
    Text := 'Noise Remover';
    Hint := 'Noise remover';
    OnChange := @Changenoise;
  end;

  Labelst1 := TfpgLabel.Create(self);
  with Labelst1 do
  begin
    Name := 'Labelst1';
    SetPosition(162, 159, 316, 15);
    FontDesc := '#Label1';
    ParentShowHint := False;
    Text := 'Folder + filename of bs2b Library';
  end;

  FilenameEdit6 := TfpgFileNameEdit.Create(self);
  with FilenameEdit6 do
  begin
    Name := 'FilenameEdit6';
    SetPosition(136, 176, 356, 24);
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 40;
  end;

  {@VFD_BODY_END: Simpleplayer}
    {%endregion}

    //////////////////////

    ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
    checkbox1.OnChange := @changecheck;
    RadioButton1.Checked := True;
    Height := 233;
             {$IFDEF Windows}
     {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    FilenameEdit2.FileName := ordir + 'lib\Windows\64bit\LibSndFile-64.dll';
    FilenameEdit3.FileName := ordir + 'lib\Windows\64bit\LibMpg123-64.dll';
    FilenameEdit5.FileName := ordir + 'lib\Windows\64bit\plugin\LibSoundTouch-64.dll';
{$else}
    FilenameEdit1.FileName := ordir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    FilenameEdit2.FileName := ordir + 'lib\Windows\32bit\LibSndFile-32.dll';
    FilenameEdit3.FileName := ordir + 'lib\Windows\32bit\LibMpg123-32.dll';
    FilenameEdit5.FileName := ordir + 'lib\Windows\32bit\plugin\libSoundTouch-32.dll';
    FilenameEdit6.FileName := ordir + 'lib\Windows\32bit\plugin\LibBs2b-32.dll';
  {$endif}
    FilenameEdit4.FileName := ordir + 'sound\test.mp3';
 {$ENDIF}

  {$IFDEF Darwin}
    opath := ordir;
    opath := copy(opath, 1, Pos('/uos', opath) - 1);
    FilenameEdit1.FileName := opath + '/lib/Mac/32bit/LibPortaudio-32.dylib';
    FilenameEdit2.FileName := opath + '/lib/Mac/32bit/LibSndFile-32.dylib';
    FilenameEdit3.FileName := opath + '/lib/Mac/32bit/LibMpg123-32.dylib';
    FilenameEdit5.FileName := opath + '/lib/Mac/32bit/plugin/libSoundTouch-32.dylib';
    FilenameEdit4.FileName := opath + 'sound/test.mp3';
            {$ENDIF}

   {$IFDEF linux}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
    FilenameEdit2.FileName := ordir + 'lib/Linux/64bit/LibSndFile-64.so';
    FilenameEdit3.FileName := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
    FilenameEdit5.FileName := ordir + 'lib/Linux/64bit/plugin/LibSoundTouch-64.so';
    FilenameEdit6.FileName := ordir + 'lib/Linux/64bit/plugin/libbs2b-64.so';
{$else}
    FilenameEdit1.FileName := ordir + 'lib/Linux/32bit/LibPortaudio-32.so';
    FilenameEdit2.FileName := ordir + 'lib/Linux/32bit/LibSndFile-32.so';
    FilenameEdit3.FileName := ordir + 'lib/Linux/32bit/LibMpg123-32.so';
    FilenameEdit5.FileName := ordir + 'lib/Linux/32bit/plugin/LibSoundTouch-32.so';
    FilenameEdit6.FileName := ordir + 'lib/Linux/32bit/plugin/libbs2b-32.so';
{$endif}
    FilenameEdit4.FileName := ordir + 'sound/test.mp3';
            {$ENDIF}

  {$IFDEF freebsd}
    {$if defined(cpu64)}
    FilenameEdit1.FileName := ordir + 'lib/FreeBSD/64bit/libportaudio-64.so';
     FilenameEdit2.FileName := ordir + 'lib/FreeBSD/64bit/libsndfile-64.so';
    FilenameEdit3.FileName := ordir + 'lib/FreeBSD/64bit/libmpg123-64.so';
    FilenameEdit5.FileName := '';
    FilenameEdit6.FileName := ordir + 'lib/FreeBSD/64bit/plugin/libbs2b-64.so';
    {$else}
    FilenameEdit1.FileName := ordir + 'lib/FreeBSD/32bit/libportaudio-32.so';
    FilenameEdit2.FileName := ordir + 'lib/FreeBSD/32bit/libsndfile-32.so';
    FilenameEdit3.FileName := ordir + 'lib/FreeBSD/32bit/libmpg123-32.so';
    FilenameEdit5.FileName := '';
{$endif}
    FilenameEdit4.FileName := ordir + 'sound/test.mp3';
{$ENDIF}
    FilenameEdit4.Initialdir := ordir + 'sound';
    FilenameEdit1.Initialdir := ordir + 'lib';
    FilenameEdit2.Initialdir := ordir + 'lib';
    FilenameEdit3.Initialdir := ordir + 'lib';
    FilenameEdit5.Initialdir := ordir + 'lib';
    vuLeft.Visible := False;
    vuRight.Visible := False;
    vuLeft.Height := 0;
    vuRight.Height := 0;
    vuright.UpdateWindowPosition;
    vuLeft.UpdateWindowPosition;
  end;

  procedure TSimpleplayer.uos_logo(Sender: TObject);
   begin
     with Custom1 do
    begin
      Canvas.GradientFill(GetClientRect, clgreen, clBlack, gdVertical);
      Canvas.TextColor := clWhite;
      Canvas.DrawText(60, 20, 'uos');
    end;
  end;

  procedure MainProc;
  var
    frm: TSimpleplayer;
  begin
    fpgApplication.Initialize;
    fpgApplication.CreateForm(TSimpleplayer, frm);
    try
     frm.Show;
      fpgApplication.Run;
    finally
      frm.Free;
    end;
  end;

begin
  MainProc;
end.
