#-----------------------------------------------------------------------------#
###############################################################################
# GYRO CALIBRATION Tool Window
###############################################################################

#my $Acc16PCalibration_IsRunning = 0; #defined above

my $GyroCalibration_ImuNr= 0; #0: Imu, 1: Imu2

my $GyroCalXPos= 80;
my $GyroCalYPos= 80;

my $GyroCalXSize= 600;
my $GyroCalYSize= 480 - 160;

my $GyroCalibrationOKCancelButtonPosX; ##is set in init
my $GyroCalibrationOKCancelButtonPosY; ##is set in init

my $GyroCalBackgroundColor = [96,96,96];

#_i is the index in the @DataMatrix, _p is the index in the recieved data format
#  data array:              index in DataMatrix        index in 'd' cmd response str
my @CdDataAx= ();           my $CdDataAx_i= 0;          my $CdDataAx_p= 0;
my @CdDataAy= ();           my $CdDataAy_i= 1;          my $CdDataAy_p= 1;
my @CdDataAz= ();           my $CdDataAz_i= 2;          my $CdDataAz_p= 2;
my @CdDataGx= ();           my $CdDataGx_i= 3;          my $CdDataGx_p= 3;
my @CdDataGy= ();           my $CdDataGy_i= 4;          my $CdDataGy_p= 4;
my @CdDataGz= ();           my $CdDataGz_i= 5;          my $CdDataGz_p= 5;
my @CdDataTemp= ();         my $CdDataTemp_i= 6;        my $CdDataTemp_p= 6;

my @CdDataAx2= ();          my $CdDataAx2_i= 7;         my $CdDataAx2_p= 7;
my @CdDataAy2= ();          my $CdDataAy2_i= 8;         my $CdDataAy2_p= 8;
my @CdDataAz2= ();          my $CdDataAz2_i= 9;         my $CdDataAz2_p= 9;
my @CdDataGx2= ();          my $CdDataGx2_i= 10;        my $CdDataGx2_p= 10;
my @CdDataGy2= ();          my $CdDataGy2_i= 11;        my $CdDataGy2_p= 11;
my @CdDataGz2= ();          my $CdDataGz2_i= 12;        my $CdDataGz2_p= 12;
my @CdDataTemp2= ();        my $CdDataTemp2_i= 13;      my $CdDataTemp2_p= 13;

my @CdDataMatrix = (
      \@CdDataAx, \@CdDataAy, \@CdDataAz,     \@CdDataGx, \@CdDataGy, \@CdDataGz,     \@CdDataTemp,
      \@CdDataAx2, \@CdDataAy2, \@CdDataAz2,  \@CdDataGx2, \@CdDataGy2, \@CdDataGz2,  \@CdDataTemp2,
  );

my $CdDataPos= 0; #position in data array
my $CdDataTimeCounter= 0; #slows down update
my $CdDataCounter= 0;


my $w_GyroCalibration= Win32::GUI::DialogBox->new( -name=> 'gyrocal_Window', -parent => $w_Main, -font=> $StdWinFont,
  -text=> $BGCStr." Gyro Calibration",
  -pos=> [$GyroCalXPos,$GyroCalYPos],
  -size=> [$GyroCalXSize,$GyroCalYSize],
  -helpbox => 0,
  -background=>$GyroCalBackgroundColor,
);
$w_GyroCalibration->SetIcon($Icon);


sub GyroCalInit{
  my $xpos= 5;
  my $ypos= 5;
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_IntroAAA_label', -font=> $StdWinFont,
    -text=> 'Gyro accelerometer calibration for', -pos=> [$xpos,$ypos],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_ImuNr_label', -font=> $StdWinFont,
    -text=> ' Imu (camera IMU) ', -pos=> [$xpos+$w_GyroCalibration->gyrocal_IntroAAA_label->Width()+3,$ypos],
    -background=>[0,255,0], #-foreground=> [0,255,255],
  );
  $xpos= 40;
  $ypos= 10 + 3*13;
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_gx_label', -font=> $StdWinFont,
    -text=> 'gx', -pos=> [$xpos,$ypos],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddTextfield( -name=> 'gyrocal_gx', -font=> $StdWinFont,
    -pos=> [$xpos+$w_GyroCalibration->gyrocal_gx_label->Width()+3,$ypos-3], -size=> [55,23],
    -align=> 'center',
    -readonly=> 1, -background=>$GyroCalibDataColor,
  );
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_gy_label', -font=> $StdWinFont,
    -text=> 'gy', -pos=> [$xpos+90,$ypos],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddTextfield( -name=> 'gyrocal_gy', -font=> $StdWinFont,
    -pos=> [$xpos+90+$w_GyroCalibration->gyrocal_gy_label->Width()+3,$ypos-3], -size=> [55,23],
    -align=> 'center',
    -readonly=> 1, -background=>$GyroCalibDataColor,
  );
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_gz_label', -font=> $StdWinFont,
    -text=> 'gz', -pos=> [$xpos+180,$ypos],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddTextfield( -name=> 'gyrocal_gz', -font=> $StdWinFont,
    -pos=> [$xpos+180+$w_GyroCalibration->gyrocal_gz_label->Width()+3,$ypos-3], -size=> [55,23],
    -align=> 'center',
    -readonly=> 1, -background=>$GyroCalibDataColor,
  );
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_temp_label', -font=> $StdWinFont,
    -text=> 'T', -pos=> [$xpos+270,$ypos],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddTextfield( -name=> 'gyrocal_temp', -font=> $StdWinFont,
    -pos=> [$xpos+270+$w_GyroCalibration->gyrocal_temp_label->Width()+3,$ypos-3], -size=> [55,23],
    -align=> 'center',
    -readonly=> 1, -background=>$GyroCalibDataColor,
  );
  $xpos= 40;
  $ypos+= 30;
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_gx_av', -font=> $StdWinFont,
    -text=> '---', -pos=> [$xpos+$w_GyroCalibration->gyrocal_gx_label->Width()+3,$ypos-3], -size=> [55,23],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_gx_sig', -font=> $StdWinFont,
    -text=> '---', -pos=> [$xpos+$w_GyroCalibration->gyrocal_gx_label->Width()+3,$ypos-3 +20], -size=> [55,23],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_gy_av', -font=> $StdWinFont,
    -text=> '---', -pos=> [$xpos+90+$w_GyroCalibration->gyrocal_gy_label->Width()+3,$ypos-3], -size=> [55,23],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_gy_sig', -font=> $StdWinFont,
    -text=> '---', -pos=> [$xpos+90+$w_GyroCalibration->gyrocal_gy_label->Width()+3,$ypos-3 +20], -size=> [55,23],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_gz_av', -font=> $StdWinFont,
    -text=> '---', -pos=> [$xpos+180+$w_GyroCalibration->gyrocal_gz_label->Width()+3,$ypos-3], -size=> [55,23],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_gz_sig', -font=> $StdWinFont,
    -text=> '---', -pos=> [$xpos+180+$w_GyroCalibration->gyrocal_gz_label->Width()+3,$ypos-3 +20], -size=> [55,23],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_temp_av', -font=> $StdWinFont,
    -text=> '---', -pos=> [$xpos+270+$w_GyroCalibration->gyrocal_temp_label->Width()+3,$ypos-3], -size=> [55,23],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddButton( -name=> 'gyrocal_Start', -font=> $StdWinFont,
    -text=> 'Start', -pos=> [$xpos+375+10,$ypos-3 -30], -width=> 80,
    -onClick => sub{ GyroCalibrationStart(); 1; }
  );
  $xpos= 360;
  $ypos= 120 +2*13-10;
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_Zero_label', -font=> $StdWinFont,
    -text=> 'Zero', -pos=> [$xpos-1-30,$ypos+1*13],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_GyroX_label', -font=> $StdWinFont,
    -text=> ' gx', -pos=> [$xpos-1,$ypos-7],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddTextfield( -name=> 'gyrocal_GyroXZero', -font=> $StdWinFont,
    -pos=> [$xpos,$ypos+1*13-4], -size=> [60,23],
    -align=> "right",
    -readonly=> 1, -background=>$GyroCalibDataColor,
  );
  $xpos+= 70;
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_GyroY_label', -font=> $StdWinFont,
    -text=> ' gy', -pos=> [$xpos-1,$ypos-7],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddTextfield( -name=> 'gyrocal_GyroYZero', -font=> $StdWinFont,
    -pos=> [$xpos,$ypos+1*13-4], -size=> [60,23],
    -align=> "right",
    -readonly=> 1, -background=>$GyroCalibDataColor,
  );
  $xpos+= 70;
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_GyroZ_label', -font=> $StdWinFont,
    -text=> ' gz', -pos=> [$xpos-1,$ypos-7],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddTextfield( -name=> 'gyrocal_GyroZZero', -font=> $StdWinFont,
    -pos=> [$xpos,$ypos+1*13-4], -size=> [60,23],
    -align=> "right",
    -readonly=> 1, -background=>$GyroCalibDataColor,
  );
  $xpos= 425;
  $ypos= 220;
  $GyroCalibrationOKCancelButtonPosX= $xpos;
  $GyroCalibrationOKCancelButtonPosY= $ypos-3;
  $w_GyroCalibration->AddButton( -name=> 'gyrocal_OK', -font=> $StdWinFont,
    -text=> 'OK', -pos=> [$xpos,$ypos-3], -width=> 80,
    -onClick => sub{
      GyroCalibrateTabSetCalibration( $w_GyroCalibration->gyrocal_GyroXZero->Text(),
                                      $w_GyroCalibration->gyrocal_GyroYZero->Text(),
                                      $w_GyroCalibration->gyrocal_GyroZZero->Text(),
                                    );
      GyroCalibrationHalt(); $w_GyroCalibration->Hide();
      TextOut( "\r\n".'Gyro Calibration Tool... DONE'."\r\n" );
      0; }
  );
  $w_GyroCalibration->AddButton( -name=> 'gyrocal_Cancel', -font=> $StdWinFont,
    -text=> 'Cancel', -pos=> [$xpos,$ypos-3 +30], -width=> 80,
    -onClick => sub{ gyrocal_Window_Terminate(); 0 }
  );
  $xpos= 45;
  $ypos= 120 + 3*13-10;
  $w_GyroCalibration->AddButton( -name=> 'gyrocal_Accept', -font=> $StdWinFont,
    -text=> 'Accept current readings', -pos=> [$xpos+50,$ypos-3], -width=> 160,
    -onClick => sub{
      GyroCalibrationSetCalibration(
        $w_GyroCalibration->gyrocal_gx_av->Text(),
        $w_GyroCalibration->gyrocal_gy_av->Text(),
        $w_GyroCalibration->gyrocal_gz_av->Text() );
      GyroCalibrationCalcCalibration();
      1;}
  );
  $xpos= 30;
  $ypos= 220;
  $w_GyroCalibration->AddLabel( -name=> 'gyrocal_Help', -font=> $StdWinFont,
    -text=> 'Carefully keep the imu at rest,'.
' and watch the gyro data. Wait until the noise'.
' stabilizes at low values, then accept the readings and press OK, or repeat.',
    -pos=> [$xpos,$ypos], -size=> [275,100],
    -background=>$GyroCalBackgroundColor, -foreground=> [255,255,255],
  );
  $w_GyroCalibration->AddTimer( 'gyrocal_Timer', 0 );
  $w_GyroCalibration->gyrocal_Timer->Interval( 10 );
} #end of GyroCalInit()


sub gyrocal_Timer_Timer{ GyroCalibrationDoTimer(); 1; }


sub gyrocal_Window_Terminate{
  GyroCalibrationHalt(); $w_GyroCalibration->Hide();
  TextOut( "\r\n".'Gyro Calibration Tool... ABORTED'."\r\n" );
  0;
}


sub GyroCalibrationShow{
  DataDisplayHalt();
  my ($x, $y) = ($w_Main->GetWindowRect())[0..1];
  $w_GyroCalibration->Move($x+80,$y+100);
  if( $f_Tab{calibrateacc}->cacc_ImuNumber->GetCurSel()==1 ){ #IMU2 selected
    $GyroCalibration_ImuNr= 1;
    $w_GyroCalibration->gyrocal_ImuNr_label->Text( '  Imu2 (2nd IMU)' );
  }else{
    $GyroCalibration_ImuNr= 0;
    $w_GyroCalibration->gyrocal_ImuNr_label->Text( ' Imu (camera IMU)' );
  }
  GyroCalibrationHalt();
  GyroCalibrationCdDataMatrixClear();
  $w_GyroCalibration->gyrocal_OK->Disable();
  GyroCalibrationSetCalibration( '', '', '' );
  $w_GyroCalibration->Show();
  TextOut( "\r\n".'Gyro Calibration Tool... ' );
#  if( $f_Tab{calibrateacc}->caac_StoreInEEprom->IsEnabled() ){ GyroCalibrationRun(); } #let it auto start when the connection was probably confirmed before
  GyroCalibrationRun(); #let it auto start
}


sub GyroCalibrationStart{
  if( $Acc16PCalibration_IsRunning ){ GyroCalibrationHalt(); }else{ GyroCalibrationRun(); }
  return 1;
}


sub GyroCalibrationRun{
  $Acc16PCalibration_IsRunning= 1;
  if( not ConnectionIsValid() ){
    if( not OpenPort() ){ ClosePort(); $Acc16PCalibration_IsRunning= 0; return; }
    ClosePort(); #close it again
    ConnectToBoardwoRead();
  }
  $w_GyroCalibration->gyrocal_Start->Text( 'Stop' );
  #$w_GyroCalibration->gyrocal_Accept->Disable();
}

sub GyroCalibrationHalt{
#  ClosePort();
  $Acc16PCalibration_IsRunning= 0;
  $w_GyroCalibration->gyrocal_Start->Text( 'Start' );
  #$w_GyroCalibration->gyrocal_Accept->Disable();
}

sub GyroCalibrationSetCalibration{
  $w_GyroCalibration->gyrocal_GyroXZero->Text( shift );
  $w_GyroCalibration->gyrocal_GyroYZero->Text( shift );
  $w_GyroCalibration->gyrocal_GyroZZero->Text( shift );
}

sub GyroCalibrationCalcCalibration{
  $w_GyroCalibration->gyrocal_OK->Enable();
}


sub GyroCalibrationCdDataMatrixClear{
  for(my $j=0; $j<512; $j++ ){
    for(my $i=0; $i<512; $i++ ){ $CdDataMatrix[$j][$i]= 0; }
  }
}

sub GyroCalibrationDoTimer{
##  if( not ConnectionIsValid() ){ GyroCalibrationHalt(); return 1; }
  if( not $Acc16PCalibration_IsRunning){ return 1; }
  #read data frame
  my $s= ExecuteCmd( 'Cd', $CMD_Cd_PARAMETER_ZAHL*2 );
  if( substr($s,length($s)-1,1) ne 'o' ){ TextOut( "\r\nSHIT '".substr($s,length($s)-1,1)."'" ); return 1; }
  my @CdData = unpack( "v$CMD_Cd_PARAMETER_ZAHL", $s );
  for(my $n=0;$n<$CMD_Cd_PARAMETER_ZAHL;$n++){
    if( substr($CDDATAFORMATSTR,$n,1) eq 's' ){ if( $CdData[$n]>32768 ){ $CdData[$n]-=65536; }  }
  }

  #Imu1: Gx, Gy, Gz
  $CdDataMatrix[$CdDataGx_i][$CdDataPos]= $CdData[$CdDataGx_p];
  $CdDataMatrix[$CdDataGy_i][$CdDataPos]= $CdData[$CdDataGy_p];
  $CdDataMatrix[$CdDataGz_i][$CdDataPos]= $CdData[$CdDataGz_p];
  #Imu1: Ax, Ay, Az
  $CdDataMatrix[$CdDataAx_i][$CdDataPos]= $CdData[$CdDataAx_p];
  $CdDataMatrix[$CdDataAy_i][$CdDataPos]= $CdData[$CdDataAy_p];
  $CdDataMatrix[$CdDataAz_i][$CdDataPos]= $CdData[$CdDataAz_p];
  #Imu1: Temp
  $CdDataMatrix[$CdDataTemp_i][$CdDataPos]= $CdData[$CdDataTemp_p];
  #Imu2: Gx, Gy, Gz
  $CdDataMatrix[$CdDataGx2_i][$CdDataPos]= $CdData[$CdDataGx2_p];
  $CdDataMatrix[$CdDataGy2_i][$CdDataPos]= $CdData[$CdDataGy2_p];
  $CdDataMatrix[$CdDataGz2_i][$CdDataPos]= $CdData[$CdDataGz2_p];
  #Imu2: Ax, Ay, Az
  $CdDataMatrix[$CdDataAx2_i][$CdDataPos]= $CdData[$CdDataAx2_p];
  $CdDataMatrix[$CdDataAy2_i][$CdDataPos]= $CdData[$CdDataAy2_p];
  $CdDataMatrix[$CdDataAz2_i][$CdDataPos]= $CdData[$CdDataAz2_p];
  #Imu2: Temp
  $CdDataMatrix[$CdDataTemp2_i][$CdDataPos]= $CdData[$CdDataTemp2_p];

  #display
  $CdDataTimeCounter++;
  if( $CdDataTimeCounter>=12 ){ $CdDataTimeCounter= 0; }

  if( $CdDataTimeCounter==0 ){ #slows down update
    if( $GyroCalibration_ImuNr != 1 ){ #IMU1
      $w_GyroCalibration->gyrocal_gx->Text( $CdData[$CdDataGx_p] );
      $w_GyroCalibration->gyrocal_gy->Text( $CdData[$CdDataGy_p] );
      $w_GyroCalibration->gyrocal_gz->Text( $CdData[$CdDataGz_p] );
      $w_GyroCalibration->gyrocal_temp->Text( sprintf('%.2f°', $CdData[$CdDataTemp_p]*0.01) );#$CdData[$CdDataTemp_p] );
    }else{ #IMU2
      $w_GyroCalibration->gyrocal_gx->Text( $CdData[$CdDataGx2_p] );
      $w_GyroCalibration->gyrocal_gy->Text( $CdData[$CdDataGy2_p] );
      $w_GyroCalibration->gyrocal_gz->Text( $CdData[$CdDataGz2_p] );
      $w_GyroCalibration->gyrocal_temp->Text( sprintf('%.2f°', $CdData[$CdDataTemp2_p]*0.01) );#$CdData[$CdDataTemp_p] );
    }
  }

  $CdDataPos++;
  if( $CdDataPos>=256 ){ $CdDataPos= 0; }

  my $gx_av= 0.0; my $gx_sig= 0.0;
  my $gy_av= 0.0; my $gy_sig= 0.0;
  my $gz_av= 0.0; my $gz_sig= 0.0;
  my $temp_av= 0.0;
  if( $GyroCalibration_ImuNr != 1 ){ #IMU1
    for(my $i=0; $i<256; $i++ ){
      $gx_av += $CdDataMatrix[$CdDataGx_i][$i];
      $gy_av += $CdDataMatrix[$CdDataGy_i][$i];
      $gz_av += $CdDataMatrix[$CdDataGz_i][$i];
      $temp_av += $CdDataMatrix[$CdDataTemp_i][$i];
    }
  }else{ #IMU2
    for(my $i=0; $i<256; $i++ ){
      $gx_av += $CdDataMatrix[$CdDataGx2_i][$i];
      $gy_av += $CdDataMatrix[$CdDataGy2_i][$i];
      $gz_av += $CdDataMatrix[$CdDataGz2_i][$i];
      $temp_av += $CdDataMatrix[$CdDataTemp2_i][$i];
    }
  }
  $gx_av = $gx_av / 256.0;
  $gy_av = $gy_av / 256.0;
  $gz_av = $gz_av / 256.0;
  $temp_av = $temp_av / 256.0;
  if( $GyroCalibration_ImuNr != 1 ){ #IMU1
    for(my $i=0; $i<256; $i++ ){
      $gx_sig += abs( $CdDataMatrix[$CdDataGx_i][$i]-$gx_av );
      $gy_sig += abs( $CdDataMatrix[$CdDataGy_i][$i]-$gy_av );
      $gz_sig += abs( $CdDataMatrix[$CdDataGz_i][$i]-$gz_av );
    }
  }else{ #IMU2
    for(my $i=0; $i<256; $i++ ){
      $gx_sig += abs( $CdDataMatrix[$CdDataGx2_i][$i]-$gx_av );
      $gy_sig += abs( $CdDataMatrix[$CdDataGy2_i][$i]-$gy_av );
      $gz_sig += abs( $CdDataMatrix[$CdDataGz2_i][$i]-$gz_av );
    }
  }

if( $CdDataTimeCounter==0 or $CdDataTimeCounter==4 or $CdDataTimeCounter==8 ){ #slows down update
  $w_GyroCalibration->gyrocal_gx_av->Text( sprintf( "%.0f", $gx_av ) );
  $w_GyroCalibration->gyrocal_gx_sig->Text( sprintf( "%.0f", $gx_sig/256.0) );
  $w_GyroCalibration->gyrocal_gy_av->Text( sprintf( "%.0f", $gy_av ) );
  $w_GyroCalibration->gyrocal_gy_sig->Text( sprintf( "%.0f", $gy_sig/256.0) );
  $w_GyroCalibration->gyrocal_gz_av->Text( sprintf( "%.0f", $gz_av ) );
  $w_GyroCalibration->gyrocal_gz_sig->Text( sprintf( "%.0f", $gz_sig/256.0) );
  $w_GyroCalibration->gyrocal_temp_av->Text( sprintf('%.2f°', $temp_av*0.01) );
}
  1;
}
