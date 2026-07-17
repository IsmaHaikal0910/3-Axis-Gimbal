#-----------------------------------------------------------------------------#
###############################################################################
# INPUTS Tool Window
###############################################################################

#my $InputsTool_IsRunning = 0; #defined above

my $InputsToolXPos= 10;
my $InputsToolYPos= 10;

my $InputsToolXSize= 580;
my $InputsToolYSize= 460; #+25;

my $InputsToolBackgroundColor = [96,96,96];

my @GiData= ();

my $CMD_Gi_PARAMETER_ZAHL = 66; #65 before v2.69a
my $GiDataFORMATSTR = 'sssssss'. #RC0 - RC6 7x
                      'sss'. #POT0 - POT2  3x
                      'ssssssssssssssss'. #VIRTUAL0 - VIRTUAL15  16x
                      'sss'.'sss'.'sss'.'sss'. #BUT, AUX0, AUX1, AUX2  12x
                      'ss'.'ss'. #AUX01, AUX012  4x
                      's'. #PREARMCHECK  1x
                      'ssssssssssssss'. #14x functions #before v2.69a: 'sssssssssssss'. #13x functions
                      'ss'.'ssss'. #2+4x functions raw
                      'sss'; #3x InputSrc

my $GiFunctionsMax = 20;
my @GiFunctionsList = (
  'Rc Pitch', 'Rc Roll', 'Rc Yaw',
  'Pan Mode Control', 'Standby', 'Camera Control', 'Re-center Camera',
  'Script1 Control', 'Script2 Control', 'Script3 Control', 'Script4 Control',
  'Pwm Out Control', 'Camera Control2', 'Retract',
  'Camera Raw', 'Camera2 Raw', 'Script1 Raw', 'Script2 Raw', 'Script3 Raw', 'Script4 Raw'
);

if( length($GiDataFORMATSTR) != $CMD_Gi_PARAMETER_ZAHL ){ die;}
if( scalar(@GiFunctionsList) != $GiFunctionsMax ){ die;}

if( $GiFunctionsMax != 14 + 6){ die;}
if( $CMD_Gi_PARAMETER_ZAHL != $FunctionInputMax + $GiFunctionsMax + 3){ die;}


my $w_InputsTool= Win32::GUI::DialogBox->new( -name=> 'inputstool_Window', -parent => $w_Main, -font=> $StdWinFont,
  -text=> $BGCStr." Inputs Tool",
  -pos=> [$InputsToolXPos,$InputsToolYPos],
  -size=> [$InputsToolXSize,$InputsToolYSize],
  -helpbox => 0,
  -background=>$InputsToolBackgroundColor,
);
$w_InputsTool->SetIcon($Icon);


sub InputsToolInit{
  my $xpos= 5;
  my $ypos= 440-2;
#  $w_InputsTool->AddLabel( -name=> 'inputstool_Help_label', -font=> $StdWinFont,
#    -text=> 'Note: For the Rc and Virtual values to appear properly, a function must have been set to the respective input.',
#    -pos=> [$xpos,$ypos], -background=>$InputsToolBackgroundColor, -foreground=> [255,255,255],
#  );

  $ypos= 5;
  $w_InputsTool->AddLabel( -name=> 'inputstool_IntroAAA_label', -font=> $StdWinFont,
    -text=> 'Raw Inputs', -pos=> [$xpos,$ypos],
    -background=>$InputsToolBackgroundColor, -foreground=> [255,255,255],
  );
  $xpos+= 10;
  $ypos= 10;
  my $dx = 40;
  my $topy = $ypos;
  for(my $i=0; $i<$FunctionInputMax; $i++ ){
    if( $i == 7 ){ $ypos += 20; }
    if( $i == 10 ){ $xpos += 80; $ypos = $topy; $dx = 55; }
    if( $i == 26 ){ $xpos += 110; $ypos = $topy; $dx = 90; }
    if( $i == 29 ){ $ypos += 20; }
    if( $i == 42 ){ $ypos += 20; }
    $ypos+= 20;
    my $s = $FunctionInputChoicesList[$i+1];
    $w_InputsTool->AddLabel( -name=> 'inputstool_I'.$i.'_label', -font=> $StdWinFont,
    -text=> $s, -pos=> [$xpos,$ypos],
    -background=>$InputsToolBackgroundColor, -foreground=> [255,255,255],
    );
    $w_InputsTool->AddLabel( -name=> 'inputstool_I'.$i.'_value', -font=> $StdWinFont,
    -text=> '-         ', -pos=> [$xpos + $dx,$ypos],
    -background=>$InputsToolBackgroundColor, -foreground=> [255,255,255],
    );
  }

  $xpos= 380;
  $ypos= 5;
  $w_InputsTool->AddLabel( -name=> 'inputstool_IntroBBB_label', -font=> $StdWinFont,
    -text=> 'Functions', -pos=> [$xpos,$ypos],
    -background=>$InputsToolBackgroundColor, -foreground=> [255,255,255],
  );
  $xpos+= 10;
  $ypos= 10;
  for(my $i=0; $i<$GiFunctionsMax; $i++ ){
    if( $i == 14 ){ $ypos += 20; }
    $ypos+= 20;
    my $s = $GiFunctionsList[$i];
    $w_InputsTool->AddLabel( -name=> 'inputstool_F'.$i.'_label', -font=> $StdWinFont,
    -text=> $s, -pos=> [$xpos,$ypos],
    -background=>$InputsToolBackgroundColor, -foreground=> [255,255,255],
    );
    $w_InputsTool->AddLabel( -name=> 'inputstool_F'.$i.'_value', -font=> $StdWinFont,
    -text=> '-         ', -pos=> [$xpos + 100,$ypos],
    -background=>$InputsToolBackgroundColor, -foreground=> [255,255,255],
    );
  }
  $ypos= 10;
  for(my $i=0; $i<3; $i++ ){
    $ypos+= 20;
    $w_InputsTool->AddLabel( -name=> 'inputstool_P'.$i.'_value', -font=> $StdWinFont,
    -text=> '-         ', -pos=> [$xpos + 140,$ypos],
    -background=>$InputsToolBackgroundColor, -foreground=> [255,255,255],
    );
  }

  $xpos= 15;
  $ypos= 400;
  my $InputsToolOKCancelButtonPosX= $xpos;
  my $InputsToolOKCancelButtonPosY= $ypos-3;
  $w_InputsTool->AddButton( -name=> 'inputstool_OK', -font=> $StdWinFont,
    -text=> 'OK', -pos=> [$xpos,$ypos-3], -width=> 80,
    -onClick => sub{
      InputsToolHalt(); $w_InputsTool->Hide();
      TextOut( "\r\n".'Inputs Tool... DONE'."\r\n" );
      0; }
  );
#  $w_InputsTool->AddButton( -name=> 'inputstool_Cancel', -font=> $StdWinFont,
#    -text=> 'Cancel', -pos=> [$xpos,$ypos-3 +30], -width=> 80,
#    -onClick => sub{ inputstool_Window_Terminate(); 0 }
#  );

  $w_InputsTool->AddTimer( 'inputstool_Timer', 0 );
  $w_InputsTool->inputstool_Timer->Interval( 100 );
} #end of InputsToolInit()


sub inputstool_Timer_Timer{ InputsToolDoTimer(); 1; }


sub inputstool_Window_Terminate{
  InputsToolHalt(); $w_InputsTool->Hide();
  TextOut( "\r\n".'Inputs Tool... ABORTED'."\r\n" );
  0;
}


sub InputsToolShow{
  DataDisplayHalt();
  my ($x, $y) = ($w_Main->GetWindowRect())[0..1];
  $w_InputsTool->Move($x+80,$y+100);
  InputsToolHalt();
  $w_InputsTool->Show();
  TextOut( "\r\n".'Inputs Tool... ' );
  InputsToolRun(); #let it auto start
}


sub InputsToolRun{
##  if( not OpenPort() ){ ClosePort(); $Acc16PCalibration_IsRunning= 0; return 1; }
##  if( not ConnectionIsValid() ){ ConnectToBoardwoRead(); }
##  if( not ConnectionIsValid() ){ $Acc16PCalibration_IsRunning= 0; return; }
#  SetDoFirstReadOut(0);
#  DisconnectFromBoard(0);
  #????$ExecuteCmdMutex= 0;
  $InputsTool_IsRunning= 1;
  if( not ConnectionIsValid() ){
    if( not OpenPort() ){ ClosePort(); $InputsTool_IsRunning= 0; return; }
    ClosePort(); #close it again
    #ConnectToBoardwoRead();
    ConnectToBoard();
  }
}


sub InputsToolHalt{
#  ClosePort();
  $InputsTool_IsRunning= 0;
}


sub InputsToolDoTimer{
##  if( not ConnectionIsValid() ){ Acc16PCalibrationHalt(); return 1; }
  if( not $InputsTool_IsRunning){ return 1; }
  #read data frame
  my $s= ExecuteCmd( 'Gi', $CMD_Gi_PARAMETER_ZAHL*2 );
  if( substr($s,length($s)-1,1) ne 'o' ){ return 1; } #TextOut( "\r\nSHIT '".substr($s,length($s)-1,1)."'" ); return 1; }
  my @GiData = unpack( "v$CMD_Gi_PARAMETER_ZAHL", $s );
  for(my $n=0; $n<$CMD_Gi_PARAMETER_ZAHL; $n++){
    if( substr($GiDataFORMATSTR,$n,1) eq 's' ){ if( $GiData[$n]>32768 ){ $GiData[$n]-=65536; }  }
  }

  for(my $i=0; $i<$FunctionInputMax; $i++ ){
    my $p = 'inputstool_I'.$i.'_value';
    $w_InputsTool->$p->Text(  $GiData[$i] );
  }

  for(my $i=0; $i<$GiFunctionsMax; $i++ ){
    my $p = 'inputstool_F'.$i.'_value';
    $w_InputsTool->$p->Text(  $GiData[$FunctionInputMax + $i] );
  }

  for(my $i=0; $i<3; $i++ ){
    my $p = 'inputstool_P'.$i.'_value';
    $w_InputsTool->$p->Text(  $GiData[$FunctionInputMax + $GiFunctionsMax + $i] );
  }

  1;
}
