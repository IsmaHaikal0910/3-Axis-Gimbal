#-----------------------------------------------------------------------------#
###############################################################################
# MAVLINK INSPECTOR Tool Window
###############################################################################

#my $MavlinkInspectorTool_IsRunning = 0; #defined above

my $MavlinkInspectorXPos= 10;
my $MavlinkInspectorYPos= 10;

my $MavlinkInspectorXSize= 500;
my $MavlinkInspectorYSize= 420 - 20;

my $MavlinkInspectorBackgroundColor = [96,96,96];

my $CMD_Gm_MSG_ZAHL = 16;
my $CMD_Gm_MSG_SIZE = 5;

my $CMD_Gm_PARAMETER_ZAHL = $CMD_Gm_MSG_ZAHL*$CMD_Gm_MSG_SIZE;
my @GmData= ();

my $MAVINSPECTORLIST_IS_BYTESPERSEC_OLD = 999999;
my $MAVINSPECTORLIST_IS_BYTESINPERSEC = 10000000;
my $MAVINSPECTORLIST_IS_BYTESOUTPERSEC = 10000001;


my $w_MavlinkInspectorTool= Win32::GUI::DialogBox->new( -name=> 'mavlinkinspector_Window', -parent => $w_Main, -font=> $StdWinFont,
  -text=> $BGCStr." Mavlink Inspector Tool",
  -pos=> [$MavlinkInspectorXPos,$MavlinkInspectorYPos],
  -size=> [$MavlinkInspectorXSize,$MavlinkInspectorYSize],
  -helpbox => 0,
  -background=>$MavlinkInspectorBackgroundColor,
);
$w_MavlinkInspectorTool->SetIcon($Icon);

my $MavlinkInspectorTool_lastblink = 0;

sub MavlinkInspectorToolSetEntry{
  my $index = shift;
  my $msgid = shift;
  my $rxpersec = shift;
  my $target = shift;
  my $p;
  if ($msgid >= 256*256*256-1) {
    $p = 'mavlinkinspector_I'.$index.'_msgname';
    $w_MavlinkInspectorTool->$p->Text('-                                      ');
    $p = 'mavlinkinspector_I'.$index.'_msgid';
    $w_MavlinkInspectorTool->$p->Text('           ');
    $p = 'mavlinkinspector_I'.$index.'_rxpersec';
    $w_MavlinkInspectorTool->$p->Text('           ');
    $p = 'mavlinkinspector_I'.$index.'_target';
    $w_MavlinkInspectorTool->$p->Text('                                ');
    return;
  }
  $p = 'mavlinkinspector_I'.$index.'_msgname';
  my $m = 'unknown';
if($msgid < 256){
  if ($msgid == 0) { $m = 'HEARTBEAT'; }
  if ($msgid == 2) { $m = 'SYSTEM_TIME'; }
  if ($msgid == 20) { $m = 'PARAM_REQUEST_READ'; }
  if ($msgid == 21) { $m = 'PARAM_REQUEST_LIST'; }
  if ($msgid == 23) { $m = 'PARAM_SET'; }
  if ($msgid == 65) { $m = 'RC_CHANNELS'; }
  if ($msgid == 75) { $m = 'COMMAND_INT'; }
  if ($msgid == 76) { $m = 'COMMAND_LONG'; }
  if ($msgid == 110) { $m = 'FILE_TRANSFER_PROTOCOL'; }
  if ($msgid == 155) { $m = 'DIGICAM_CONTROL'; } # deprecated
  if ($msgid == 156) { $m = 'MOUNT_CONFIGURE'; } # deprecated
  if ($msgid == 157) { $m = 'MOUNT_CONTROL'; } # deprecated
  if ($msgid == 183) { $m = 'AUTOPILOT_VERSION_REQUEST'; }
}elsif($msgid < 60000){
  if ($msgid == 281) { $m = 'GIMBAL_MANAGER_STATUS'; }
  if ($msgid == 282) { $m = 'GIMBAL_MANAGER_SET_ATTITUDE'; } # not actually supported by STorM32
  if ($msgid == 284) { $m = 'GIMBAL_DEVICE_SET_ATTITUDE'; }
  if ($msgid == 286) { $m = 'AUTOPILOT_STATE_FOR_GIMBAL_DEVICE'; }
  if ($msgid == 287) { $m = 'GIMBAL_MANAGER_SET_PITCHYAW'; } # not actually supported by STorM32
  if ($msgid == 288) { $m = 'GIMBAL_MANAGER_SET_MANUAL_CONTROL'; } # not actually supported by STorM32
  if ($msgid == 320) { $m = 'PARAM_EXT_REQUEST_READ'; }
  if ($msgid == 321) { $m = 'PARAM_EXT_REQUEST_LIST'; }
  if ($msgid == 323) { $m = 'PARAM_EXT_SET'; }
  if ($msgid == 385) { $m = 'TUNNEL'; }
  if ($msgid == 412) { $m = 'REQUEST_EVENT'; }
  if ($msgid == 420) { $m = 'RADIO_RC_CHANNELS'; }
}else{
  if ($msgid == 60011) { $m = 'STORM32_GIMBAL_MANAGER_STATUS'; }
  if ($msgid == 60012) { $m = 'STORM32_GIMBAL_MANAGER_CONTROL'; }
  if ($msgid == 60013) { $m = 'STORM32_GIMBAL_MANAGER_CONTROL_PITCHYAW'; }
  if ($msgid == 60014) { $m = 'STORM32_GIMBAL_MANAGER_CORRECT_ROLL'; }
  if ($msgid == 60000) { $m = 'AUTOPILOT_STATE_FOR_GIMBAL_DEVICE_EXT'; }
}
  #$m = 'STORM32_GIMBAL_MANAGER_CONTROL_PITCHYAW';
  $w_MavlinkInspectorTool->$p->Text($m);
  $p = 'mavlinkinspector_I'.$index.'_msgid';
  $w_MavlinkInspectorTool->$p->Text($msgid);
  $p = 'mavlinkinspector_I'.$index.'_rxpersec';
  $w_MavlinkInspectorTool->$p->Text($rxpersec." / s");
  $p = 'mavlinkinspector_I'.$index.'_target';
  my $t = '';
  if ($target == 1) { $t = 'gimbal' }
  elsif ($target == 2) { $t = 'camera' }
  elsif ($target == 3) { $t = 'gimbal,camera' }
  else{ $t = 'broadcast' }
  $w_MavlinkInspectorTool->$p->Text($t);
}


sub MavlinkInspectorToolInit{
  my $xpos= 5;
  my $ypos= 5;
  $w_MavlinkInspectorTool->AddLabel( -name=> 'mavlinkinspector_IntroAAA_label', -font=> $StdWinFont,
    -text=> 'Message', -pos=> [$xpos+10,$ypos],
    -background=>$MavlinkInspectorBackgroundColor, -foreground=> [255,255,255],
  );
  $w_MavlinkInspectorTool->AddLabel( -name=> 'mavlinkinspector_IntroBBB_label', -font=> $StdWinFont,
    -text=> 'msg id', -pos=> [$xpos+10+280,$ypos],
    -background=>$MavlinkInspectorBackgroundColor, -foreground=> [255,255,255],
  );
  $w_MavlinkInspectorTool->AddLabel( -name=> 'mavlinkinspector_IntroCCC_label', -font=> $StdWinFont,
    -text=> 'rate', -pos=> [$xpos+10+330,$ypos],
    -background=>$MavlinkInspectorBackgroundColor, -foreground=> [255,255,255],
  );
  $w_MavlinkInspectorTool->AddLabel( -name=> 'mavlinkinspector_IntroDDD_label', -font=> $StdWinFont,
    -text=> 'target', -pos=> [$xpos+10+380,$ypos],
    -background=>$MavlinkInspectorBackgroundColor, -foreground=> [255,255,255],
  );

  $xpos+= 10;
  $ypos= 10;
  for(my $i = 0; $i < $CMD_Gm_MSG_ZAHL - 1; $i++){
    $ypos+= 20;
    $w_MavlinkInspectorTool->AddLabel( -name=> 'mavlinkinspector_I'.$i.'_msgname', -font=> $StdWinFont,
    -text=> '                                                                                             ',
    -pos=> [$xpos,$ypos],
    -background=>$MavlinkInspectorBackgroundColor, -foreground=> [255,255,255],
    );
    $w_MavlinkInspectorTool->AddLabel( -name=> 'mavlinkinspector_I'.$i.'_msgid', -font=> $StdWinFont,
    -text=> '            ', -pos=> [$xpos + 280,$ypos],
    -background=>$MavlinkInspectorBackgroundColor, -foreground=> [255,255,255],
    );
    $w_MavlinkInspectorTool->AddLabel( -name=> 'mavlinkinspector_I'.$i.'_rxpersec', -font=> $StdWinFont,
    -text=> '            ', -pos=> [$xpos + 330,$ypos],
    -background=>$MavlinkInspectorBackgroundColor, -foreground=> [255,255,255],
    );
    $w_MavlinkInspectorTool->AddLabel( -name=> 'mavlinkinspector_I'.$i.'_target', -font=> $StdWinFont,
    -text=> '                               ', -pos=> [$xpos + 380,$ypos],
    -background=>$MavlinkInspectorBackgroundColor, -foreground=> [255,255,255],
    );
  }

  $ypos+= 20;
  $w_MavlinkInspectorTool->AddLabel( -name=> 'mavlinkinspector_BytesInPerSec_label', -font=> $StdWinFont,
    -text=> 'total in', -pos=> [$xpos+10+280,$ypos],
    -background=>$MavlinkInspectorBackgroundColor, -foreground=> [255,255,255],
  );
  $w_MavlinkInspectorTool->AddLabel( -name=> 'mavlinkinspector_BytesInPerSec_bytespersec', -font=> $StdWinFont,
    -text=> '-                            ', -pos=> [$xpos+330+10,$ypos],
    -background=>$MavlinkInspectorBackgroundColor, -foreground=> [255,255,255],
  );

  $ypos+= 20;
  $w_MavlinkInspectorTool->AddLabel( -name=> 'mavlinkinspector_BytesOutPerSec_label', -font=> $StdWinFont,
    -text=> 'total out', -pos=> [$xpos+10+280,$ypos],
    -background=>$MavlinkInspectorBackgroundColor, -foreground=> [255,255,255],
  );
  $w_MavlinkInspectorTool->AddLabel( -name=> 'mavlinkinspector_BytesOutPerSec_bytespersec', -font=> $StdWinFont,
    -text=> '-                            ', -pos=> [$xpos+330+10,$ypos],
    -background=>$MavlinkInspectorBackgroundColor, -foreground=> [255,255,255],
  );

  $xpos= 15;
  $ypos= $MavlinkInspectorYSize-60;
  my $MavlinkInspectorOKCancelButtonPosX= $xpos;
  my $MavlinkInspectorOKCancelButtonPosY= $ypos-3;
  $w_MavlinkInspectorTool->AddButton( -name=> 'mavlinkinspector_OK', -font=> $StdWinFont,
    -text=> 'OK', -pos=> [$xpos,$ypos-3], -width=> 80,
    -onClick => sub{
      MavlinkInspectorToolHalt(); $w_MavlinkInspectorTool->Hide();
      TextOut( "\r\n".'Mavlink Inspector Tool... DONE'."\r\n" );
      0; }
  );

  $w_MavlinkInspectorTool->AddTimer( 'mavlinkinspector_Timer', 0 );
  $w_MavlinkInspectorTool->mavlinkinspector_Timer->Interval( 250 );
} #end of MavlinkInspectorToolInit()


sub mavlinkinspector_Timer_Timer{ MavlinkInspectorToolDoTimer(); 1; }


sub mavlinkinspector_Window_Terminate{
  MavlinkInspectorToolHalt(); $w_MavlinkInspectorTool->Hide();
  TextOut( "\r\n".'Mavlink Inspector Tool... ABORTED'."\r\n" );
  0;
}


sub MavlinkInspectorToolShow{
  DataDisplayHalt();
  my ($x, $y) = ($w_Main->GetWindowRect())[0..1];
  $w_MavlinkInspectorTool->Move($x+80,$y+100);
  MavlinkInspectorToolHalt();
  $w_MavlinkInspectorTool->Show();
  TextOut( "\r\n".'Mavlink Inspector Tool... ' );
  MavlinkInspectorToolRun(); #let it auto start
}


sub MavlinkInspectorToolRun{
  $MavlinkInspectorTool_IsRunning = 1;
  if( not ConnectionIsValid() ){
    if( not OpenPort() ){ ClosePort(); $MavlinkInspectorTool_IsRunning = 0; return; }
    ClosePort(); #close it again
    ConnectToBoard();
  }
}


sub MavlinkInspectorToolHalt{
  $MavlinkInspectorTool_IsRunning = 0;
}


sub MavlinkInspectorToolDoTimer{
  if( not $MavlinkInspectorTool_IsRunning){ return 1; }
  #read data frame
  my $s = ExecuteCmd( 'Gm', $CMD_Gm_PARAMETER_ZAHL );
  if( substr($s,length($s)-1,1) ne 'o' ){ TextOut( "\r\nSHIT '".substr($s,length($s)-1,1)."'" ); return 1; }
  my @GmData = unpack( "C$CMD_Gm_PARAMETER_ZAHL", $s );

  #for(my $n=0;$n<$CMD_Gm_PARAMETER_ZAHL;$n++){ my $val = $GmData[$n]; TextOut("$val,"); }
  #TextOut("\n");

  my %msgid_list = ();
  my $version_of_CMD_Gm = 0; #0: v0, no bytes per sec, 1: v1: bytes per sec, 2: v2, bytes in/out per sec
  my $bytes_in_per_sec = 0;
  my $bytes_out_per_sec = 0;
  for(my $n = 0; $n < $CMD_Gm_MSG_ZAHL; $n++){
    my $msgid = 0;
    $msgid = $GmData[$n*$CMD_Gm_MSG_SIZE + 0];
    $msgid += $GmData[$n*$CMD_Gm_MSG_SIZE + 1] * 256;
    $msgid += $GmData[$n*$CMD_Gm_MSG_SIZE + 2] * 256*256;
    if ($msgid == $MAVINSPECTORLIST_IS_BYTESPERSEC_OLD) {
      $bytes_in_per_sec = $GmData[$n*$CMD_Gm_MSG_SIZE+3] + 256*$GmData[$n*$CMD_Gm_MSG_SIZE+4];
      $version_of_CMD_Gm = 1;
    } elsif ($msgid == $MAVINSPECTORLIST_IS_BYTESINPERSEC) {
      $bytes_in_per_sec = $GmData[$n*$CMD_Gm_MSG_SIZE+3] + 256*$GmData[$n*$CMD_Gm_MSG_SIZE+4];
      $version_of_CMD_Gm = 2;
    } elsif ($msgid == $MAVINSPECTORLIST_IS_BYTESOUTPERSEC) {
      $bytes_out_per_sec = $GmData[$n*$CMD_Gm_MSG_SIZE+3] + 256*$GmData[$n*$CMD_Gm_MSG_SIZE+4];
      $version_of_CMD_Gm = 2;
    } elsif ($msgid < 256*256*256-1) {
      $msgid_list{$msgid} = $n;
    }
  }

  my $index = 0;
  foreach my $msgid (sort {$a <=> $b} keys(%msgid_list)) {
    my $n = $msgid_list{$msgid};
    MavlinkInspectorToolSetEntry($index, $msgid, $GmData[$n*$CMD_Gm_MSG_SIZE+3], $GmData[$n*$CMD_Gm_MSG_SIZE+4]);
    $index++;
  }

  for(my $n = $index; $n < $CMD_Gm_MSG_ZAHL - 2; $n++){
      MavlinkInspectorToolSetEntry($n, 256*256*256, 0, 0);
  }

  if ($version_of_CMD_Gm >= 1) {
    $w_MavlinkInspectorTool->mavlinkinspector_BytesInPerSec_bytespersec->Text($bytes_in_per_sec." Bytes/s");
  }
  if ($version_of_CMD_Gm >= 2) {
    $w_MavlinkInspectorTool->mavlinkinspector_BytesOutPerSec_bytespersec->Text($bytes_out_per_sec." Bytes/s");
  }

  1;
}
