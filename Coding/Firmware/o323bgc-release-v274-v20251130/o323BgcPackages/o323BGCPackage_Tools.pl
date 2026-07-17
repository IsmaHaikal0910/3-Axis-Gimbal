#-----------------------------------------------------------------------------#
###############################################################################
# SHARE SETTINGS Tool Window
###############################################################################
# -> SHARE SETTINGS Tool Window
#    CHECK NT MODULE VERSIONS Tool Window
#    CHANGE BOARD CONFIGURATION Tool Window
#    EDIT BOARD NAME Tool Window
#    GUI BAUDRATE Tool Window
#    NTLogger RTC Configuration Tool Window
#    UPDATE Tool Window
#    NT Module CLI Tool Window
###############################################################################
#-----------------------------------------------------------------------------#
my $ShareSettingsIsInitialized = 0;

my $ShareSettingsBackgroundColor= [96,96,96];

my $ShareSettingsXsize= 3*380 + 10; #780
my $ShareSettingsYsize= 1800; #870-32; # -50;

#my $ssWinFont = Win32::GUI::Font->new(-name=>$StdWinFontName, -size=>7, -bold => 0, );

my $w_ShareSettings = Win32::GUI::DialogBox->new( -name=> 'sharesettings_Window', -parent => $w_Main,
  -text=> 'o323BGC Share Settings', -size=> [$ShareSettingsXsize,$ShareSettingsYsize],
  -helpbox => 0,
  #-background=>$ShareSettingsBackgroundColor,
  #-sizable => 1,
  #-resizable => 1,
);
$w_ShareSettings->SetIcon($Icon);

sub sharesettings_Window_Terminate{ $w_ShareSettings->Hide(); 0; }
sub sharesettings_OK_Click{ $w_ShareSettings->Hide(); 0; }
sub sharesettings_ScreenShotMini_Click{ return sharesettings_ScreenShot_Click(); }

my $ScreenShotFile_lastdir = $ExePath;

sub sharesettings_ScreenShot_Click{
  my $file= Win32::GUI::GetSaveFileName( -owner=> $w_Main,
    -title=> 'Save Share Settings ScreenShot to File',
    -nochangedir=> 1,
    -directory=> $ScreenShotFile_lastdir,
    -defaultextension=> '.png',
    -filter=> ['*.png'=>'*.png','*.jpg'=>'*.jpg','*.bmp'=>'*.bmp','All files' => '*.*'],
    -pathmustexist=> 1,
    -overwriteprompt=> 1,
    -noreadonlyreturn => 1,
    -explorer=>0,
  );
  if( $file ){
    $FirmwareHexFile_lastdir= $file;
    my $DC= $w_ShareSettings->GetDC();
    my $bmap = Win32::GUI::DIBitmap->newFromDC($DC);
    $bmap->SaveToFile( $file );#, JPEG ); #,  JPEG_QUALITYSUPERB );
    TextOut("\r\nScreenShot of Share Settings saved to $file.\r\n");
  }elsif( Win32::GUI::CommDlgExtendedError() ){ $w_Main->MessageBox("Some error occured, sorry",'ERROR'); }
  1;
}

sub ShareSettingsInit{
  if( $ShareSettingsIsInitialized > 0 ){ return; }
  $ShareSettingsIsInitialized = 1;
  my $xpos = 400; #15;
  my $ypos = 15;
  $w_ShareSettings->AddLabel( -name=> 'sharesettings_BGC', #-font=> $StdWinFont,
    -text=> "OlliW's Brushless Gimbal Controller Tool ".$BGCStr."Tool\r\n$VersionStr\r\n",
    -pos=> [$xpos,$ypos],  -height=>50,
    #-background=>$ShareSettingsBackgroundColor, -foreground=> [255,255,255],
  );
  $xpos = 15;
  $ypos = 15;
  $w_ShareSettings->AddLabel( -name=> 'sharesettings_Header_name', #-font=> $StdWinFont,
    -text=> '', -pos=> [$xpos,$ypos], -width=> 160,  -height=>50,
    #-background=>$ShareSettingsBackgroundColor, -foreground=> [255,255,255],
  );
  $w_ShareSettings->AddLabel( -name=> 'sharesettings_Header_value', #-font=> $StdWinFont,
    -text=> '', -pos=> [$xpos+170,$ypos], -width=> 200, -height=>50,
    #-background=>$ShareSettingsBackgroundColor, -foreground=> [255,255,255],
  );
  $ypos = 110 -40;
  $xpos = 15;
  $w_ShareSettings->AddLabel( -name=> 'sharesettings_Text1_name', #-font=> $StdWinFont,
    -text=> '', -pos=> [$xpos,$ypos], -width=> 160+50,  -height=>$ShareSettingsYsize-100-75 +40,#+25,
    #-background=>$ShareSettingsBackgroundColor, -foreground=> [255,255,255],
  );
  $w_ShareSettings->AddLabel( -name=> 'sharesettings_Text1_value', #-font=> $StdWinFont,
    -text=> '', -pos=> [$xpos+170,$ypos], -width=> 50,  -height=>$ShareSettingsYsize-100-75 +40,#+25,
    #-background=>$ShareSettingsBackgroundColor, -foreground=> [255,255,255],
  );
  $w_ShareSettings->AddLabel( -name=> 'sharesettings_Text1_value2', #-font=> $StdWinFont,
    -text=> '', -pos=> [$xpos+170+60,$ypos], -width=> 130,  -height=>$ShareSettingsYsize-100-75 +40,#+25,
    #-background=>$ShareSettingsBackgroundColor, -foreground=> [255,255,255],
  );
  $xpos = 15+380;
  $w_ShareSettings->AddLabel( -name=> 'sharesettings_Text2_name', #-font=> $StdWinFont,
    -text=> '', -pos=> [$xpos,$ypos], -width=> 160+50,  -height=>$ShareSettingsYsize-100-75 +40,#+25,
    #-background=>$ShareSettingsBackgroundColor, -foreground=> [255,255,255],
  );
  $w_ShareSettings->AddLabel( -name=> 'sharesettings_Text2_value', #-font=> $StdWinFont,
    -text=> '', -pos=> [$xpos+170,$ypos], -width=> 50,  -height=>$ShareSettingsYsize-100-75 +40,#+25,
    #-background=>$ShareSettingsBackgroundColor, -foreground=> [255,255,255],
  );
  $w_ShareSettings->AddLabel( -name=> 'sharesettings_Text2_value2', #-font=> $StdWinFont,
    -text=> '', -pos=> [$xpos+170+60,$ypos], -width=> 130,  -height=>$ShareSettingsYsize-100-75 +40,#+25,
    #-background=>$ShareSettingsBackgroundColor, -foreground=> [255,255,255],
  );
  $xpos = 15+2*380;
  $w_ShareSettings->AddLabel( -name=> 'sharesettings_Text3_name', #-font=> $StdWinFont,
    -text=> '', -pos=> [$xpos,$ypos], -width=> 160+50,  -height=>$ShareSettingsYsize-100-75 +40,#+25,
    #-background=>$ShareSettingsBackgroundColor, -foreground=> [255,255,255],
  );
  $w_ShareSettings->AddLabel( -name=> 'sharesettings_Text3_value', #-font=> $StdWinFont,
    -text=> '', -pos=> [$xpos+170,$ypos], -width=> 50,  -height=>$ShareSettingsYsize-100-75 +40,#+25,
    #-background=>$ShareSettingsBackgroundColor, -foreground=> [255,255,255],
  );
  $w_ShareSettings->AddLabel( -name=> 'sharesettings_Text3_value2', #-font=> $StdWinFont,
    -text=> '', -pos=> [$xpos+170+60,$ypos], -width=> 130,  -height=>$ShareSettingsYsize-100-75 +40,#+25,
    #-background=>$ShareSettingsBackgroundColor, -foreground=> [255,255,255],
  );
  $ypos= $ShareSettingsYsize -63;
  $w_ShareSettings->AddButton( -name=> 'sharesettings_ScreenShot', #-font=> $StdWinFont,
    -text=> 'Save ScreenShot', -pos=> [$ShareSettingsXsize-203,$ypos], -width=> 120, -height=> 26,
  );
  $w_ShareSettings->AddButton( -name=> 'sharesettings_ScreenShotMini', #-font=> $StdWinFont,
    -text=> 'Save Screenshot', -pos=> [0,0], -width=> 120, -height=> 26,
  );
  $w_ShareSettings->AddButton( -name=> 'sharesettings_OK', #-font=> $StdWinFont,
    -text=> 'OK', -pos=> [$ShareSettingsXsize-203,$ypos], -width=> 80, -height=> 26,
  );
}

sub ShareSettingsShow{
  my $header_name=''; my $header_value='';
  my $text1_name=''; my $text1_value='';  my $text1_value2='';
  my $text2_name=''; my $text2_value='';  my $text2_value2='';
  my $text3_name=''; my $text3_value='';  my $text3_value2='';
  my $count = 0;
  if( $ActiveBoardConfiguration == $BOARDCONFIGURATION_IS_FOC ){
    $w_ShareSettings->sharesettings_BGC->Text(
      "OlliW's Brushless Gimbal Controller Tool ".$BGCStr."Tool\r\n$VersionStr\r\n".
      "for T-STorM32 (for encoders)" );
  }else{
    $w_ShareSettings->sharesettings_BGC->Text(
      "OlliW's Brushless Gimbal Controller Tool ".$BGCStr."Tool\r\n$VersionStr\r\n".
      "for STorM32-NT" );
  }
  foreach my $Option (@OptionList){
    if( $Option->{type} eq 'SCRIPT' ){ next; }
    if( OptionToSkip($Option) ){
      $header_name.= $Option->{name} . "\r\n";
      $header_value.= ': ' . GetOptionField($Option,0) . "\r\n";
      next;
    }
    if( $ActiveBoardConfiguration == $BOARDCONFIGURATION_IS_FOC ){
      if( ($Option->{foc} == 1) or ($Option->{foc} == 3) ){ next; }
    }else{
      if( ($Option->{foc} == 2) or ($Option->{foc} == 4) ){ next; }
    }
    $count++;
  }
  my $countthird =  int( $count/3+0.51 ) +1;
  my $counttext1 =  0;
  $count = 0;
  foreach my $Option (@OptionList){
    if( $Option->{type} eq 'SCRIPT' ){ next; }
    if( OptionToSkip($Option) ){ next; }
    if( $ActiveBoardConfiguration == $BOARDCONFIGURATION_IS_FOC ){
      if( ($Option->{foc} == 1) or ($Option->{foc} == 3) ){ next; }
    }else{
      if( ($Option->{foc} == 2) or ($Option->{foc} == 4) ){ next; }
    }
    if( $count < $countthird ){
      $text1_name.= $Option->{name} . "\r\n";
      $text1_value.= ': ' . GetOptionField($Option,0) . "\r\n";
      $text1_value2.= ': ' . $Option->{textfield}->Text() . "\r\n";
      $counttext1++;
    }elsif( $count < 2*$countthird ){
      $text2_name.= $Option->{name} . "\r\n";
      $text2_value.= ': ' . GetOptionField($Option,0) . "\r\n";
      $text2_value2.= ': ' . $Option->{textfield}->Text() . "\r\n";
    }else{
      $text3_name.= $Option->{name} . "\r\n";
      $text3_value.= ': ' . GetOptionField($Option,0) . "\r\n";
      $text3_value2.= ': ' . $Option->{textfield}->Text() . "\r\n";
    }
    $count++;
  }
  $w_ShareSettings->sharesettings_Header_name->Text( $header_name );
  $w_ShareSettings->sharesettings_Header_value->Text( $header_value );
  $w_ShareSettings->sharesettings_Text1_name->Text( $text1_name );
  $w_ShareSettings->sharesettings_Text1_value->Text( $text1_value );
  $w_ShareSettings->sharesettings_Text1_value2->Text( $text1_value2 );
  $w_ShareSettings->sharesettings_Text2_name->Text( $text2_name );
  $w_ShareSettings->sharesettings_Text2_value->Text( $text2_value );
  $w_ShareSettings->sharesettings_Text2_value2->Text( $text2_value2 );
  $w_ShareSettings->sharesettings_Text3_name->Text( $text3_name );
  $w_ShareSettings->sharesettings_Text3_value->Text( $text3_value );
  $w_ShareSettings->sharesettings_Text3_value2->Text( $text3_value2 );

  my ($tw,$th)= $w_ShareSettings->sharesettings_Text1_name->GetTextExtentPoint32(
                  $text1_name,
                  $w_ShareSettings->sharesettings_Text1_name->GetFont()
                );
  $w_ShareSettings->Height( 140 + $th*$counttext1 + 5);

  my $desk = Win32::GUI::GetDesktopWindow();
  my $dw = Win32::GUI::Width($desk);
  my $dh = Win32::GUI::Height($desk);
  my $ssw = $w_ShareSettings->Width();
  my $ssh = $w_ShareSettings->Height();
  my $x = ($dw-$ssw)/2; if($x<10){$x=10;}
  my $y = ($dh-$ssh)/2-10; if($y<10){$y=10;}
  $w_ShareSettings->Move( $x, $y );
  $w_ShareSettings->sharesettings_ScreenShot->Move( $ssw-85-25 - 160, $ssh-50-10 );
  #$w_ShareSettings->sharesettings_ScreenShotMini->Move( $ssw- 26 -8, 2 );
  $w_ShareSettings->sharesettings_ScreenShotMini->Move( $ssw-125-25, 10 );
  $w_ShareSettings->sharesettings_OK->Move( $ssw-85-25, $ssh-50-10 );

  $w_ShareSettings->Show();
}

# Ende # SHARE SETTINGS Window
#####################



#-----------------------------------------------------------------------------#
###############################################################################
# CHECK NT MODULE VERSIONS Tool Window
###############################################################################
#    SHARE SETTINGS Tool Window
# -> CHECK NT MODULE VERSIONS Tool Window
#    CHANGE BOARD CONFIGURATION Tool Window
#    EDIT BOARD NAME Tool Window
#    GUI BAUDRATE Tool Window
#    NTLogger RTC Configuration Tool Window
#    UPDATE Tool Window
#    NT Module CLI Tool Window
###############################################################################
#-----------------------------------------------------------------------------#
my $CheckNtVersionsIsInitialized = 0;

my $CheckNtVersionsBackgroundColor= [96,96,96];

my $CheckNtVersionsXsize= 330;
my $CheckNtVersionsYsize= 250;

my $w_CheckNtVersions = Win32::GUI::DialogBox->new( -name=> 'checkntversions_Window', -parent => $w_Main,
  -text=> 'NT Modules Firmware Versions', -size=> [$CheckNtVersionsXsize,$CheckNtVersionsYsize],
  -helpbox => 0,
);
$w_CheckNtVersions->SetIcon($Icon);

sub checkntversions_Window_Terminate{ $w_CheckNtVersions->Hide(); 0; }
sub checkntversions_OK_Click{ $w_CheckNtVersions->Hide(); 0; }

sub CheckNtVersionsInit{
  if( $CheckNtVersionsIsInitialized>0 ){ return; }
  $CheckNtVersionsIsInitialized = 1;
  my $xpos = 15;
  my $ypos = 15;
  $w_CheckNtVersions->AddLabel( -name=> 'checkntversions_Intro',
    -text=> 'Status of all NT modules found on the NT bus:',
    -pos=> [$xpos,$ypos],  -height=>20, -width=>$CheckNtVersionsYsize-20,
  );
  $ypos += 2*13;
  #a maximum of 7 NT modules: Imu1, Imu2, Pitch, Roll, Yaw, Logger, Imu3
  for (my $i=0; $i<7; $i++){
    $w_CheckNtVersions->AddLabel( -name=> 'checkntversions_MessageModule'.$i, #-font=> $StdWinFont,
      -text=> 'tt',
      -pos=> [$xpos+15,$ypos],  -height=>$CheckNtVersionsXsize-30, -width=>$CheckNtVersionsYsize-20,
    );
    $w_CheckNtVersions->AddLabel( -name=> 'checkntversions_MessageStatus'.$i, #-font=> $StdWinFont,
      -text=> 'tt',
      -pos=> [$xpos+90,$ypos],  -height=>$CheckNtVersionsXsize-30, -width=>$CheckNtVersionsYsize-20,
    );
    $ypos += 15;
  }
#  $ypos += 8*13; #each line is 13 height
  $ypos += 13-2;
  $w_CheckNtVersions->AddLabel( -name=> 'checkntversions_Result',
    -text=> 'tt',
    -pos=> [$xpos,$ypos],  -height=>20, -width=>$CheckNtVersionsYsize-20,
  );

  $w_CheckNtVersions->AddButton( -name=> 'checkntversions_OK', #-font=> $StdWinFont,
    -text=> 'OK', -pos=> [$CheckNtVersionsXsize-203,$ypos], -width=> 80, -height=> 26,
  );
}

sub CheckNtVersionsShow
{
my $ptr = shift;
my @modulestoupgrade = @{$ptr}; #was passed in as reference

  my $cnt = 0;
  for (my $i=0; $i<7; $i++){
    if( $i < scalar @modulestoupgrade ){
      my $mod = $modulestoupgrade[$i];
      $w_CheckNtVersions->{'checkntversions_MessageModule'.$i}->Text($mod->{name}.':');
      my $s2 = '';
      if( $mod->{uptodate} ){
        $s2 .= 'is up to date'."\n";
        $w_CheckNtVersions->{'checkntversions_MessageStatus'.$i}->Change(-foreground => [0,128,0]);
      }else{
        $s2 .= 'please upgrade (curr: '.$mod->{curversion}.'  latest: '.$mod->{latestversion}.')'."\n";
        $w_CheckNtVersions->{'checkntversions_MessageStatus'.$i}->Change(-foreground => [128,0,0]);
        $cnt++;
      }
      $w_CheckNtVersions->{'checkntversions_MessageStatus'.$i}->Text($s2);
    }else{
      $w_CheckNtVersions->{'checkntversions_MessageModule'.$i}->Text('');
      $w_CheckNtVersions->{'checkntversions_MessageStatus'.$i}->Text('');
    }
  }
  if( $cnt == 0 ){
    $w_CheckNtVersions->checkntversions_Result->Text( 'All NT modules are up to date!' );
  }else{
    $w_CheckNtVersions->checkntversions_Result->Text( 'NT modules which need upgrade:  '.$cnt );
  }

  my ($x, $y) = ($w_Main->GetWindowRect())[0..1];
  $w_CheckNtVersions->Move($x+200,$y+100);

  my $desk = Win32::GUI::GetDesktopWindow();
  my $dw = Win32::GUI::Width($desk);
  my $dh = Win32::GUI::Height($desk);
  my $ssw = $w_CheckNtVersions->Width();
  my $ssh = $w_CheckNtVersions->Height();
  $w_CheckNtVersions->checkntversions_OK->Move( $ssw-85-25, $ssh-50-10 );

  $w_CheckNtVersions->Show();
}


sub CheckNtVersionsShow1
{
my $ptr = shift;
my @modulestoupgrade = @{$ptr}; #was passed in as reference

  my $s = '';
  my $cnt = 0;
  foreach my $mod (@modulestoupgrade){
    $s .= '  '.$mod->{name}.':'.TrimStrToLength(' ',13-length($mod->{name}));
    if( $mod->{uptodate} ){
      $s .= 'is up to date'."\n";
    }else{
      $s .= 'please upgrade (curr: '.$mod->{curversion}.'  latest: '.$mod->{latestversion}.')'."\n";
      $cnt++;
    }
  }
  if( $cnt == 0 ){
    $s .= "\n".'All NT modules are up to date!'
  }else{
    $s .= "\n".'NT modules which need upgrade:  '.$cnt;
  }

  my $res = $w_Main->MessageBox(
      "Status of all NT modules found on the NT bus:\n\n".$s,
      'NT Modules Firmware Versions', 0x0030 );#0x0040 MB_ICONASTERISK (used for information)
}

# Ende # CheckNtVersions Window
#####################




#-----------------------------------------------------------------------------#
###############################################################################
# CHANGE BOARD CONFIGURATION Tool Window
###############################################################################
#    SHARE SETTINGS Tool Window
#    CHECK NT MODULE VERSIONS Tool Window
# -> CHANGE BOARD CONFIGURATION Tool Window
#    EDIT BOARD NAME Tool Window
#    GUI BAUDRATE Tool Window
#    NTLogger RTC Configuration Tool Window
#    UPDATE Tool Window
#    NT Module CLI Tool Window
###############################################################################
#-----------------------------------------------------------------------------#
my $ChangeBoardConfigurationIsInitialized = 0;

my $ChangeBoardConfigurationBackgroundColor= [96,96,96];

my $ChangeBoardConfigurationXsize= 400;
my $ChangeBoardConfigurationYsize= 270+13; #470;

my $w_ChangeBoardConfiguration= Win32::GUI::DialogBox->new( -name=> 'changeboardconfig_Window', -parent => $w_Main, -font=> $StdWinFont,
##  -text=> "o323BGC Change Board Configuration Tool",
  -text=> "o323BGC Change Encoder Support Tool",
  -size=> [$ChangeBoardConfigurationXsize,$ChangeBoardConfigurationYsize],
  -helpbox => 0,
  -background=>$ChangeBoardConfigurationBackgroundColor,
);
$w_ChangeBoardConfiguration->SetIcon($Icon);

sub changeboardconfig_Window_Terminate{ changeboardconfig_Cancel_Click(); 0; }

sub ChangeBoardConfigurationInit{
  if( $ChangeBoardConfigurationIsInitialized>0 ){ return; }
  $ChangeBoardConfigurationIsInitialized = 1;
  my $xpos= 20;
  my $ypos= 20;
  $w_ChangeBoardConfiguration->AddLabel( -name=> 'changeboardconfig_Text1', -font=> $StdWinFont,
    -text=> "This tool allows you to enable/disable the encoder support.",
    -pos=> [$xpos,$ypos], -width=> $ChangeBoardConfigurationXsize-20,  -height=>30,
    -background=>$ChangeBoardConfigurationBackgroundColor, -foreground=> [255,255,255],
  );
  $ypos+= 35 ;
  $w_ChangeBoardConfiguration->AddLabel( -name=> 'changeboardconfig_Text2', -font=> $StdWinFont,
    -text=> '-',
    -pos=> [$xpos,$ypos], -width=> $ChangeBoardConfigurationXsize-50,  -height=>8*13+13,
   -background=> $CGREY128, -foreground=> $CWHITE,
  );
  $ypos+= 30;
  $w_ChangeBoardConfiguration->AddCombobox( -name=> 'changeboardconfig_BoardConfiguration', -font=> $StdWinFont,
    -pos=> [$ChangeBoardConfigurationXsize/2-40-2,$ypos-2], -size=> [80,160],
    -dropdown=> 1, -vscroll=>1,
  );
  $w_ChangeBoardConfiguration->changeboardconfig_BoardConfiguration->SetDroppedWidth(60);
  $w_ChangeBoardConfiguration->changeboardconfig_BoardConfiguration->Add( ('off','on') );
  $xpos= 20;
  $ypos= $ChangeBoardConfigurationYsize -90;
  $w_ChangeBoardConfiguration->AddButton( -name=> 'changeboardconfig_OK', -font=> $StdWinFont,
    -text=> 'OK', -pos=> [$ChangeBoardConfigurationXsize/2-40-2,$ypos], -width=> 80,
  );
  $w_ChangeBoardConfiguration->AddButton( -name=> 'changeboardconfig_Cancel', -font=> $StdWinFont,
    -text=> 'Cancel', -pos=> [$ChangeBoardConfigurationXsize/2-40-2,$ypos+30], -width=> 80,
  );
}

sub ChangeBoardConfigurationShow{
  DataDisplayHalt();
  my ($x, $y) = ($w_Main->GetWindowRect())[0..1];
  $w_ChangeBoardConfiguration->Move($x+150,$y+100);

  $w_ChangeBoardConfiguration->changeboardconfig_BoardConfiguration->Hide();
  $w_ChangeBoardConfiguration->changeboardconfig_OK->Disable();
  $w_ChangeBoardConfiguration->Show();
##  TextOut( "\r\n".'Change Board Configuration Tool... ' );
  TextOut( "\r\n".'Change Encoder Support Tool... ' );
##  if( not ConnectionIsValid() ){ goto WERROR; }
if( not ConnectionIsValid() ){
  $w_ChangeBoardConfiguration->changeboardconfig_Text2->Text(
    'Please select the new encoder support:' ."\r\n". "\r\n". "\r\n". "\r\n". "\r\n".
    'When done press >OK<; or press >Cancel< to abort.' . "\r\n". "\r\n".
    'NOTE: No board connected, so only GUI will be reconfigured!' );
}else{
  $w_ChangeBoardConfiguration->changeboardconfig_Text2->Text(
    'Please select the new encoder support:' ."\r\n". "\r\n". "\r\n". "\r\n". "\r\n".
    'When done press >OK<; or press >Cancel< to abort.' . "\r\n". "\r\n".
    'NOTE: On >OK< the new setting will be stored immediately to the EEPROM; it will however become effective only at the next power up!' );
}
  if( $ActiveBoardConfiguration == $BOARDCONFIGURATION_IS_FOC ){
    $w_ChangeBoardConfiguration->changeboardconfig_BoardConfiguration->Select(1);
  }else{
    $w_ChangeBoardConfiguration->changeboardconfig_BoardConfiguration->Select(0);
  }
  $w_ChangeBoardConfiguration->changeboardconfig_BoardConfiguration->Show();
  $w_ChangeBoardConfiguration->changeboardconfig_OK->Enable();
  return 1;
WERROR:
  $w_ChangeBoardConfiguration->changeboardconfig_Text2->Text(
    'No connection to board!' . "\r\n". "\r\n".
    'Press >Cancel<.' );
  return 0;
}

sub changeboardconfig_Cancel_Click{
  ##ClosePort();
##  TextOut( "\r\n".'Change Board Configuration Tool... ABORTED!'."\r\n" );
  TextOut( "\r\n".'Change Encoder Support Tool... ABORTED!'."\r\n" );
  $w_ChangeBoardConfiguration->Hide();
  0;
}

sub changeboardconfig_OK_Click{
if( not ConnectionIsValid() ){
  my $bcf = $w_ChangeBoardConfiguration->changeboardconfig_BoardConfiguration->SelectedItem();
  if( $bcf ) {
    BoardConfiguration_HandleChange($BOARDCONFIGURATION_IS_FOC);
  } else {
    BoardConfiguration_HandleChange($BOARDCONFIGURATION_IS_DEFAULT);
  }
  TextOut( "\r\n".'Change Encoder Support Tool... DONE!'."\r\n" );
  $w_ChangeBoardConfiguration->Hide();
  return 0;
}

  my $bcf = $w_ChangeBoardConfiguration->changeboardconfig_BoardConfiguration->SelectedItem();
  TextOut( "\r\n".'xf... ' );
  SetExtendedTimoutFirst(1000); #storing to Eeprom can take a while! so extend timeout
  my $res= ExecuteCmdwCrc( 'xf', HexstrToStr('0'.$bcf.'00') );
  if( substr($res,length($res)-1,1) ne 'o' ){ TextOut( 'hhhhhkashdhn' ); } #this should never happen
  TextOut( ' ok' );

  TextOut( "\r\n".'xx... ' );
  $res= ExecuteCmd( 'xx' );
  if( substr($res,length($res)-1,1) ne 'o' ){ TextOut( 'hhhhhkashdhn' ); } #this should never happen
  TextOut( ' ok' );
  TextOut( "\r\n".'disconnect ...');
  SetDoFirstReadOut(0); #to suppress "Please do first ..." line
  DisconnectFromBoard(0);
  TextOut( "\r\n".'waiting for a moment before reconnecting ...');
  _delay_ms( 1500 );
##  TextOut( "\r\n".'Change Board Configuration Tool... DONE!'."\r\n" );
  TextOut( "\r\n".'Change Encoder Support Tool... DONE!'."\r\n" );
  $w_ChangeBoardConfiguration->Hide();

  ConnectToBoard();
  0;
}

# Ende # CHANGE BOARD CONFIGURATION Tool Window
#####################




#-----------------------------------------------------------------------------#
###############################################################################
# EDIT BOARD NAME Tool Window
###############################################################################
#    SHARE SETTINGS Tool Window
#    CHECK NT MODULE VERSIONS Tool Window
#    CHANGE BOARD CONFIGURATION Tool Window
# -> EDIT BOARD NAME Tool Window
#    GUI BAUDRATE Tool Window
#    NTLogger RTC Configuration Tool Window
#    UPDATE Tool Window
#    NT Module CLI Tool Window
###############################################################################
#-----------------------------------------------------------------------------#
my $EditBoardNameIsInitialized = 0;

my $EditBoardNameBackgroundColor= [96,96,96];

my $EditBoardNameXsize= 410;
my $EditBoardNameYsize= 270; #470;

my $w_EditBoardName= Win32::GUI::DialogBox->new( -name=> 'editboardname_Window', -parent => $w_Main, -font=> $StdWinFont,
  -text=> "o323BGC Edit Board Name Tool",
  -size=> [$EditBoardNameXsize,$EditBoardNameYsize],
  -helpbox => 0,
  -background=>$EditBoardNameBackgroundColor,
);
$w_EditBoardName->SetIcon($Icon);

sub editboardname_Window_Terminate{ editboardname_Cancel_Click(); 0; }

sub EditBoardNameInit{
  if( $EditBoardNameIsInitialized>0 ){ return; }
  $EditBoardNameIsInitialized = 1;
  my $xpos= 20;
  my $ypos= 20;
  $w_EditBoardName->AddLabel( -name=> 'editboardname_Text1', -font=> $StdWinFont,
    -text=> "This tool allows you to change the name of the STorM32-BGC board.",
    -pos=> [$xpos,$ypos], -width=> $EditBoardNameXsize-20,  -height=>30,
    -background=>$EditBoardNameBackgroundColor, -foreground=> [255,255,255],
  );
  $ypos+= 35 ;
  $w_EditBoardName->AddLabel( -name=> 'editboardname_Text2', -font=> $StdWinFont,
    -text=> '-',
    -pos=> [$xpos,$ypos], -width=> $EditBoardNameXsize-50,  -height=>8*13,
    -background=> $CGREY128, -foreground=> $CWHITE,
  );
  $ypos+= 30;
  $w_EditBoardName-> AddTextfield( -name=> 'editboardname_Name', -font=> $StdWinFont,
    -pos=> [$EditBoardNameXsize/2-70-2,$ypos-3], -size=> [140,23],
  );
  $w_EditBoardName->editboardname_Name->SetLimitText(16);
  $xpos= 20;
  $ypos= $EditBoardNameYsize -90;
  $w_EditBoardName->AddButton( -name=> 'editboardname_OK', -font=> $StdWinFont,
    -text=> 'OK', -pos=> [$EditBoardNameXsize/2-40-2,$ypos], -width=> 80,
  );
  $w_EditBoardName->AddButton( -name=> 'editboardname_Cancel', -font=> $StdWinFont,
    -text=> 'Cancel', -pos=> [$EditBoardNameXsize/2-40-2,$ypos+30], -width=> 80,
  );
}

sub EditBoardNameShow{
  DataDisplayHalt();
  my ($x, $y) = ($w_Main->GetWindowRect())[0..1];
  $w_EditBoardName->Move($x+150,$y+100);

  $w_EditBoardName->editboardname_Name->Hide();
  $w_EditBoardName->editboardname_OK->Disable();
  $w_EditBoardName->Show();
  TextOut( "\r\n".'Edit Board Name Tool... ' );
  if( not ConnectionIsValid() ){ goto WERROR; }
  my $res = ExecuteCmd( 'v', 54 );
  if( substr($res,length($res)-1,1) ne 'o' ){ DisconnectFromBoard(0); goto WERROR; }
  TextOut( "\r\n".'Reading... ' );
  #check
  TextOut( 'ok' );
  $w_EditBoardName->editboardname_Name->Text( CleanLeftRightStr(substr($res,16,16)) );
  $w_EditBoardName->editboardname_Text2->Text(
    'Please enter the new name:' ."\r\n". "\r\n". "\r\n". "\r\n". "\r\n".
    'When done press >OK<; or press >Cancel< to abort.' . "\r\n". "\r\n".
    'NOTE: On >OK< the new name will be stored immediately to the EEPROM!' );
  $w_EditBoardName->editboardname_Name->Show();
  $w_EditBoardName->editboardname_OK->Enable();
  return 1;
WERROR:
  $w_EditBoardName->editboardname_Text2->Text(
    'No connection to board!' . "\r\n". "\r\n".
    'Press >Cancel<.' );
  return 0;
}

sub editboardname_Cancel_Click{
#  ClosePort();
  TextOut( "\r\n".'Edit Board Name Tool... ABORTED!'."\r\n" );
  $w_EditBoardName->Hide();
  0;
}

sub editboardname_OK_Click{
  my $name= substr( $w_EditBoardName->editboardname_Name->Text() ,0,16);
  $name = TrimStrToLength( $name, 16 );
  TextOut( "\r\n".'xn... ' );
  SetExtendedTimoutFirst(1000); #storing to Eeprom can take a while! so extend timeout
  my $res = ExecuteCmdwCrc( 'xn', $name, 0 );
  if( substr($res,length($res)-1,1) ne 'o' ){ TextOut( 'iahfkashfkshjkf' ); } #this should never happen
  TextOut( 'ok' );
  $NameToOptionHash{'Name'}->{textfield}->Text( $name );
  TextOut( "\r\n".'Edit Board Name Tool... DONE!'."\r\n" );
  $w_EditBoardName->Hide();
  0;
}


# Ende # EDIT BOARD NAME Tool Window
###############################################################################



#-----------------------------------------------------------------------------#
###############################################################################
# GUI BAUDRATE Tool Window
###############################################################################
#    SHARE SETTINGS Tool Window
#    CHECK NT MODULE VERSIONS Tool Window
#    CHANGE BOARD CONFIGURATION Tool Window
#    EDIT BOARD NAME Tool Window
# -> GUI BAUDRATE Tool Window
#    NTLogger RTC Configuration Tool Window
#    UPDATE Tool Window
#    NT Module CLI Tool Window
###############################################################################
#-----------------------------------------------------------------------------#
my $GuiBaudrateIsInitialized = 0;

my $GuiBaudrateBackgroundColor= [96,96,96];

my $GuiBaudrateXsize= 400;
my $GuiBaudrateYsize= 270+13; #470;

my $w_GuiBaudrate= Win32::GUI::DialogBox->new( -name=> 'guibaudrate_Window', -parent => $w_Main, -font=> $StdWinFont,
  -text=> "o323BGC GUI Baudrate Tool",
  -size=> [$GuiBaudrateXsize,$GuiBaudrateYsize],
  -helpbox => 0,
  -background=>$GuiBaudrateBackgroundColor,
);
$w_GuiBaudrate->SetIcon($Icon);

sub guibaudrate_Window_Terminate{ guibaudrate_Cancel_Click(); 0; }

sub GuiBaudrateInit{
  if( $GuiBaudrateIsInitialized>0 ){ return; }
  $GuiBaudrateIsInitialized = 1;
  my $xpos= 20;
  my $ypos= 20;
  $w_GuiBaudrate->AddLabel( -name=> 'guibaudrate_Text1', -font=> $StdWinFont,
    -text=> "This tool allows you to change the GUI's baudrate for communicating with the STorM32 board.",
    -pos=> [$xpos,$ypos], -width=> $GuiBaudrateXsize-20-30,  -height=>30,
    -background=>$GuiBaudrateBackgroundColor, -foreground=> [255,255,255],
  );
  $ypos+= 35 ;
  $w_GuiBaudrate->AddLabel( -name=> 'guibaudrate_Text2', -font=> $StdWinFont,
    -text=> '-',
    -pos=> [$xpos,$ypos], -width=> $GuiBaudrateXsize-50,  -height=>8*13+13,
   -background=> $CGREY128, -foreground=> $CWHITE,
  );
  $ypos+= 30;
  $w_GuiBaudrate->AddCombobox( -name=> 'guibaudrate_Baudrate', -font=> $StdWinFont,
    -pos=> [$GuiBaudrateXsize/2-40-2,$ypos-2], -size=> [80,160],
    -dropdown=> 1, -vscroll=>1,
  );
  $w_GuiBaudrate->guibaudrate_Baudrate->SetDroppedWidth(60);
  $w_GuiBaudrate->guibaudrate_Baudrate->Add( ('9600','19200','38400','57600','115200','230400','460800') );
  $xpos= 20;
  $ypos= $GuiBaudrateYsize -90;
  $w_GuiBaudrate->AddButton( -name=> 'guibaudrate_OK', -font=> $StdWinFont,
    -text=> 'OK', -pos=> [$GuiBaudrateXsize/2-40-2,$ypos], -width=> 80,
  );
  $w_GuiBaudrate->AddButton( -name=> 'guibaudrate_Cancel', -font=> $StdWinFont,
    -text=> 'Cancel', -pos=> [$GuiBaudrateXsize/2-40-2,$ypos+30], -width=> 80,
  );
}

sub GuiBaudrateShow{
  DisconnectFromBoard(0);
  my ($x, $y) = ($w_Main->GetWindowRect())[0..1];
  $w_GuiBaudrate->Move($x+150,$y+100);

  $w_GuiBaudrate->guibaudrate_Baudrate->Hide();
  $w_GuiBaudrate->guibaudrate_OK->Disable();
  $w_GuiBaudrate->Show();
  TextOut( "\r\n".'GUI Baudrate Tool... ' );

  $w_GuiBaudrate->guibaudrate_Text2->Text(
    'Please enter the new baudrate:' ."\r\n". "\r\n". "\r\n". "\r\n". "\r\n".
    'When done press >OK<; or press >Cancel< to abort.' . "\r\n". "\r\n".
    'NOTE: On >OK< the new baudrate will become effective immediately.' );
  if( $Baudrate<=9600 ){
    $w_GuiBaudrate->guibaudrate_Baudrate->Select(0);
  }elsif( $Baudrate<=19200 ){
    $w_GuiBaudrate->guibaudrate_Baudrate->Select(1);
  }elsif( $Baudrate<=38400 ){
    $w_GuiBaudrate->guibaudrate_Baudrate->Select(2);
  }elsif( $Baudrate<=57600 ){
    $w_GuiBaudrate->guibaudrate_Baudrate->Select(3);
  }elsif( $Baudrate<=115200 ){
    $w_GuiBaudrate->guibaudrate_Baudrate->Select(4);
  }elsif( $Baudrate<=230400 ){
    $w_GuiBaudrate->guibaudrate_Baudrate->Select(5);
  }elsif( $Baudrate<=460800 ){
    $w_GuiBaudrate->guibaudrate_Baudrate->Select(6);
  }else{
    $w_GuiBaudrate->guibaudrate_Baudrate->Select(4);
  }
  $w_GuiBaudrate->guibaudrate_Baudrate->Show();
  $w_GuiBaudrate->guibaudrate_OK->Enable();
  return 1;
}

sub guibaudrate_Cancel_Click{
  TextOut( "\r\n".'GUI Baudrate Tool... ABORTED!'."\r\n" );
  $w_GuiBaudrate->Hide();
  0;
}

sub guibaudrate_OK_Click{
  my $bps = $w_GuiBaudrate->guibaudrate_Baudrate->SelectedItem();
  if( $bps==0 ){
    $Baudrate = 9600;
  }elsif( $bps==1 ){
    $Baudrate = 19200;
  }elsif( $bps==2 ){
    $Baudrate = 38400;
  }elsif( $bps==3 ){
    $Baudrate = 57600;
  }elsif( $bps==4 ){
    $Baudrate = 115200;
  }elsif( $bps==5 ){
    $Baudrate = 230400;
  }elsif( $bps==6 ){
    $Baudrate = 460800;
  }else{
    $Baudrate = 115200;
  }
  TextOut( 'Baudrate set to '.$Baudrate.' bps'."\r\n" );
  TextOut( "\r\n".'GUI Baudrate Tool... DONE!'."\r\n" );
  $w_GuiBaudrate->Hide();
  0;
}


# Ende # GUI BAUDRATE Tool Window
###############################################################################







#-----------------------------------------------------------------------------#
###############################################################################
# NTLogger RTC Configuration Tool Window
###############################################################################
#    SHARE SETTINGS Tool Window
#    CHECK NT MODULE VERSIONS Tool Window
#    CHANGE BOARD CONFIGURATION Tool Window
#    EDIT BOARD NAME Tool Window
#    GUI BAUDRATE Tool Window
# -> NTLogger RTC Configuration Tool Window
#    UPDATE Tool Window
#    NT Module CLI Tool Window
###############################################################################
#-----------------------------------------------------------------------------#
my $RTCConfigIsInitialized = 0;

my $RTCConfigBackgroundColor= [96,96,96];

my $RTCConfigXsize= 400;
my $RTCConfigYsize= 270+13+13; #470;

my $w_RTCConfig= Win32::GUI::DialogBox->new( -name=> 'rtcconfig_Window', -parent => $w_Main, -font=> $StdWinFont,
##  -text=> "o323BGC Change Board Configuration Tool",
  -text=> "o323BGC NTLogger RTC Tool",
  -size=> [$RTCConfigXsize,$RTCConfigYsize],
  -helpbox => 0,
  -background=>$RTCConfigBackgroundColor,
);
$w_RTCConfig->SetIcon($Icon);

sub rtcconfig_Window_Terminate{ rtcconfig_Cancel_Click(); 0; }

sub RTCConfigInit{
  if ($RTCConfigIsInitialized > 0) { return; }
  $RTCConfigIsInitialized = 1;
  my $xpos= 20;
  my $ypos= 20;
  $w_RTCConfig->AddLabel( -name=> 'rtcconfig_Text1', -font=> $StdWinFont,
    -text=> "This tool allows you to set the NTLogger RTC date and time.",
    -pos=> [$xpos,$ypos], -width=> $RTCConfigXsize-20,  -height=>30,
    -background=>$RTCConfigBackgroundColor, -foreground=> [255,255,255],
  );
  $ypos+= 35 ;
  $w_RTCConfig->AddLabel( -name=> 'rtcconfig_Text2', -font=> $StdWinFont,
    -text=> ' ',
    -pos=> [$xpos,$ypos], -width=> $RTCConfigXsize-50,  -height=>8*13+13+13,
   -background=> $CGREY128, -foreground=> $CWHITE,
  );
  $ypos+= 4*13 ;
  $w_RTCConfig->AddLabel( -name=> 'rtcconfig_DateTime', -font=> $StdWinFont,
    -text=> ' ',
    -pos=> [$RTCConfigXsize/2-80,$ypos], -width=> 160,  -height=>13,
   -background=> $CGREY128, -foreground=> $CWHITE,
  );
  $xpos= 20;
  $ypos= $RTCConfigYsize -90;
  $w_RTCConfig->AddButton( -name=> 'rtcconfig_OK', -font=> $StdWinFont,
    -text=> 'OK', -pos=> [$RTCConfigXsize/2-40-2,$ypos], -width=> 80,
  );
  $w_RTCConfig->AddButton( -name=> 'rtcconfig_Cancel', -font=> $StdWinFont,
    -text=> 'Cancel', -pos=> [$RTCConfigXsize/2-40-2,$ypos+30], -width=> 80,
  );
  $w_RTCConfig->AddTimer( 'rtcconfig_Timer', 0 );
  $w_RTCConfig->rtcconfig_Timer->Interval( 4 );
}

sub RTCConfigShow{
  DataDisplayHalt();
  my ($x, $y) = ($w_Main->GetWindowRect())[0..1];
  $w_RTCConfig->Move($x+150,$y+100);

  $w_RTCConfig->rtcconfig_OK->Disable();
  $w_RTCConfig->Show();
  TextOut( "\r\n".'Set NTLogger RTC Tool... ' );
  if( not ConnectionIsValid() ){ goto WERROR; }

  my $s = ExecuteCmdwCrc( 'Nc', HexstrToStr('0B'), 34 );
#TextOut('!'.StrToHexstr($s)."!\r\n");
  if( substr($s,length($s)-1,1) ne 'o' ){ goto WERROR; }
  my $logger_datetime = 'unknown';
  if( substr($s,1,1) eq 'o' ){
    my @NcLoggerData = unpack( "SCCCCC", substr($s,2,7) );
    $logger_datetime = $NcLoggerData[2].'.'.$NcLoggerData[1].'.'.$NcLoggerData[0].' '.
                       sprintf("%.2u:%.2u:%.2u",$NcLoggerData[3],$NcLoggerData[4],$NcLoggerData[5]);
  }

  $w_RTCConfig->rtcconfig_Text2->Text(
    'Date and time stored in logger: '.$logger_datetime."\r\n".
    'Current date and time:' ."\r\n". "\r\n". "\r\n".
    "\r\n".
    "\r\n". "\r\n".
    'Press >OK< to store the new date and time in the RTC; or press >Cancel< to abort.' . "\r\n"
  );

  rtcconfig_Timer_Timer();

  $w_RTCConfig->rtcconfig_OK->Enable();
  return 1;
WERROR:
  $w_RTCConfig->rtcconfig_Text2->Text(
    'No connection to board!' . "\r\n". "\r\n".
    'Press >Cancel<.' );
  return 0;
}

sub rtcconfig_Cancel_Click{
  TextOut( "\r\n".'Set NTLogger RTC Tool... ABORTED!'."\r\n" );
  $w_RTCConfig->Hide();
  0;
}

sub rtcconfig_Timer_Timer{
  my $datestring = localtime();
  $datestring =~ s/  / /ig;
  my @dl = split(' ', $datestring);
  $datestring = $dl[0].' '.$dl[2].' '.$dl[1].' '.$dl[4].'  '.$dl[3];
  $w_RTCConfig->rtcconfig_DateTime->Text($datestring);
  1;
}

sub rtcconfig_OK_Click{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
  $year = $year + 1900;
  $mon = $mon + 1;
  my $datestring = localtime();
  my $dts = UIntToHexstrSwapped($year).UCharToHexstr($mon).UCharToHexstr($mday).
            UCharToHexstr($hour).UCharToHexstr($min).UCharToHexstr($sec);
  TextOut( "\r\n".$datestring );
  TextOut( "\r\n".$sec."-".$min."-".$hour." ".$mday.".".$mon.".".$year );
  TextOut( "\r\n".$dts );

  TextOut( "\r\n".'Cl... ' );
  my $res= ExecuteCmdwCrc( 'Cl', HexstrToStr($dts) );
  if( substr($res,length($res)-1,1) ne 'o' ){ TextOut( 'usdgfsjdzgf' ); } #this should never happen
  TextOut( ' ok' );

  TextOut( "\r\n".'Set NTLogger RTC Tool... DONE!'."\r\n" );
  $w_RTCConfig->Hide();
  0;
}

# Ende # Set NTLogger RTC Tool Window
###############################################################################





#-----------------------------------------------------------------------------#
###############################################################################
# UPDATE Tool Window
###############################################################################
#    SHARE SETTINGS Tool Window
#    CHECK NT MODULE VERSIONS Tool Window
#    CHANGE BOARD CONFIGURATION Tool Window
#    EDIT BOARD NAME Tool Window
#    GUI BAUDRATE Tool Window
#    NTLogger RTC Configuration Tool Window
# -> UPDATE Tool Window
#    NT Module CLI Tool Window
###############################################################################
#-----------------------------------------------------------------------------#
# ShellExecute may nozt work since it returns immediately and doesn't wait for called to finish
# http://www.perl-community.de/bat/poard/thread/5223
# Win32::SetChildShowWindow(0);  #damit system kein Fenster öffnet
# system( "owH_extract.exe in.txt out.txt" );
my $UpdateIsInitialized = 0;

my %MonthHash = ( 'Jan'=>'01', 'Feb'=>'02', 'Mar'=>'03', 'Apr'=>'04', 'Mai'=>'05', 'June'=>'06', 'July'=>'07',
                  'Aug'=>'08', 'Sep'=>'09', 'Oct'=>'10', 'Nov'=>'11', 'Dez'=>'12', );

my $UpdateBackgroundColor = [96,96,96];

my $UpdateLatestVersionStr = '';
my $UpdateLatestDate = '';

my $UpdateXsize = 450;
my $UpdateYsize = 205+23;

my $w_Update= Win32::GUI::DialogBox->new( -name=> 'update_Window', -parent => $w_Main, -font=> $StdWinFont,
  -text=> "o323BGC Update Tool", -size=> [$UpdateXsize,$UpdateYsize],
  -helpbox => 0,
  -background=>$UpdateBackgroundColor,
);
$w_Update->SetIcon($Icon);


sub update_Window_Terminate{ $w_Update->Hide(); 0; }
sub update_OK_Click{ $w_Update->Hide(); 0; }


sub UpdateInit
{
  if( $UpdateIsInitialized>0 ){ return; }
  $UpdateIsInitialized = 1;
  my $xpos= 20;
  my $ypos= 20;
  $w_Update->AddLabel( -name=> 'update_Text1_label', -font=> $StdWinFont,
    -text=> 'This tool checks for updates, and lets you download them.',
    -pos=> [$xpos,$ypos], -width=> 420,  -height=>30,
    -background=>$UpdateBackgroundColor, -foreground=> [255,255,255],
  );
  $ypos+= 35;
  $w_Update->AddLabel( -name=> 'update_Text2_label', -font=> $StdWinFont,
    -text=> '-',
    -pos=> [$xpos,$ypos], -width=> 400,  -height=>70 + 23,
    -background=> $CGREY128, -foreground=> $CWHITE,
  );
  $xpos= 20;
  $ypos= $UpdateYsize -60;
  $w_Update->AddButton( -name=> 'update_DownloadAndSave', -font=> $StdWinFont,
    -text=> 'Download and Save', -pos=> [$UpdateXsize/2-80,$ypos], -width=> 160,
  );
  $w_Update->update_DownloadAndSave->Hide();
  $w_Update->AddButton( -name=> 'update_OK', -font=> $StdWinFont,
    -text=> 'OK', -pos=> [$UpdateXsize/2-40,$ypos], -width=> 80,
  );
  $w_Update->update_OK->Hide();
}


sub UpdateShow
{
  DataDisplayHalt();
  $w_Update->update_DownloadAndSave->Hide();
  $w_Update->update_OK->Hide();
  my ($x, $y) = ($w_Main->GetWindowRect())[0..1];
  $w_Update->Move($x+150,$y+100);
  $w_Update->update_Text2_label->Text( 'Checking git for updates... Please wait!' );
  $w_Update->Show();
  Win32::GUI::DoEvents();
  sleep(1);
  my ($version,$date,$zipfilename, $betaversion,$betastr,$betadate,$betazipfilename) = Update_CheckGitForLatestVersion();
#  ($UpdateLatestVersion,$UpdateLatestDate) = Update_CheckGitForLatestVersion();
  if( $version == 0 ){
    $w_Update->update_Text2_label->Text(
      'Checking git for updates... ABORTED!'."\n".'Connecting to git failed.'
    );
    return 0;
  }
#$VersionStr = '27. Mai. 2018 v2.38a';
  $VersionStr =~ /^(\d+?)\. (.+?)\.? (\d+?) v(.+?)$/;
#TextOut( "\r\n".$1 ); TextOut( "\r\n".$2 );  TextOut( "\r\n".$3 );  TextOut( "\r\n".$4 );
#TextOut( "\r\n".$MonthHash{$2} );
  my $currentdate = $3.$MonthHash{$2}.$1;
  my $currentversionstr = $4;
  $currentversionstr =~ s/\.//g; #remove '.'
  my $currentversion = $currentversionstr;
  $currentversion =~ s/\D//g; #remove all non-digits
  my $currentbetastr = $currentversionstr;;
  $currentbetastr =~ s/\d//g; #remove all digits
#  my $s = 'Your firmware release:    v'.$currentversion.$currentbetastr.'-v'.$currentdate."\r\n";
  my $s = 'Your firmware release:    v'.$currentversionstr.'-v'.$currentdate."\n"."\n";
  $s.= 'Latest firmware release: v'.$version.'-v'.$date."\n";
  $s.= 'Latest beta release:        v'.$betaversion.$betastr.'-v'.$betadate."\n";
  $s.= "\n";
  $w_Update->update_Text2_label->Text( $s );
  if( ($currentversion >= $version) and ($currentversionstr ge $betaversion.$betastr) ){
    $s .= 'You have the latest firmware installed :)'."\n";
    $w_Update->update_Text2_label->Text( $s );
    $w_Update->update_OK->Show();
    return 0;
  }
  if( ($currentversion >= $version) or ($currentbetastr ne '') ){
    $s.= 'A newer beta version v'.$betaversion.$betastr.' is available, do you want to download the zip file?'."\n";
    ($UpdateLatestVersionStr,$UpdateLatestDate) = ($betaversion.$betastr,$betadate);
  }else{
    $s.= 'A newer firmware version v'.$version.' is available, do you want to download the zip file?'."\n";
    ($UpdateLatestVersionStr,$UpdateLatestDate) = ($version,$date);
  }
  $w_Update->update_Text2_label->Text( $s );
  $w_Update->update_DownloadAndSave->Enable();
  $w_Update->update_DownloadAndSave->Show();
}


my $UpdateZipFileDir_lastdir = $ExePath;


sub update_DownloadAndSave_Click
{
  $w_Update->update_DownloadAndSave->Hide();
  my $zipfilename= 'o323bgc-release-v'.$UpdateLatestVersionStr.'-v'.$UpdateLatestDate;
  $w_Update->update_Text2_label->Text( 'Download firmware '. $zipfilename .'.zip... '."\n" );
  my $dir = Win32::GUI::BrowseForFolder( -owner=> $w_Main,
    -title=> 'Select Firmware Zip File Directory',
    -directory=> $UpdateZipFileDir_lastdir,
    -folderonly=> 1,
  );
  if( $dir ){
    $UpdateZipFileDir_lastdir = $dir;
    my $s = 'Downloading firmware '. $zipfilename .'.zip... Please wait!'."\n";
    $w_Update->update_Text2_label->Text( $s );
    if( Update_DownloadLatestVersionFromGit($zipfilename,$dir) ){
      $s.= 'Downloading ... DONE'."\n" . "\n" . 'Please unzip/extract the dowloaded file. Have fun :)'."\n";
    }else{
      $s.= 'Downloading ... ABORTED'."\n" . 'Connection to git failed.';
    }
    $w_Update->update_Text2_label->Text( $s );
    $w_Update->update_OK->Enable();
    $w_Update->update_OK->Show();
  }elsif( Win32::GUI::CommDlgExtendedError() ){ $w_Main->MessageBox("Some error occured, sorry",'ERROR'); }
  1;
}

sub Update_CheckGitForLatestVersion
{
#http://www.perlhowto.com/executing_external_cocmdmmands
  #get github directory page as html
  Win32::SetChildShowWindow(0);
  my $res = system(
        'bin\wget\wget', '-q', '--no-check-certificate', '--no-hsts',
        '-Ogithub-firmware-directory-list-html',
        'https://github.com/olliw42/storm32bgc/tree/master/firmware%20binaries%20%26%20gui'
        );
  if( $res != 0 ){ return (0,''); }
  #load github directory page
  my $directorieshtml = '';
  open( F, "<github-firmware-directory-list-html");
  while(<F>){ $directorieshtml .= $_; }
  close( F );
  system( 'del', '"github-firmware-directory-list-html"' );
  #scan and extract the .zip files from downloaded github page
  my @directories = ( $directorieshtml =~ /"name":".*?(o323bgc-release-.*?\.zip)"/g  ); #only get .zip
  #get latest official and beta versions
  my $version = 0;
  my $date = '';
  my $zipfilename = '';
  my $betaversion = 0;
  my $betastr = '';
  my $betadate = '';
  my $betazipfilename = '';
  foreach my $s (@directories){
#TextOut( "\r\n".$s );
    $s =~ /o323bgc-release-v(\d+)(\w*)-v(\d+)\.zip/;
    my $ver = $1;
    my $beta = $2;
    my $d = $3;
#TextOut( "\r\n".$ver." ".$beta." ".$d );
    if( $beta ne '' ){
      if( ($ver > $betaversion) or (($ver == $betaversion) and ($beta gt $betastr)) ){
        $betaversion = $ver; $betastr = $beta; $betadate = $d; $betazipfilename = $s;
      }
    }else{
      if( $ver > $version ){ $version = $ver; $date = $d; $zipfilename = $s;}
    }
  }
  return ($version,$date,$zipfilename, $betaversion,$betastr,$betadate,$betazipfilename);
}

sub Update_DownloadLatestVersionFromGit
{
#http://www.perlhowto.com/executing_external_commands
  my $zipfilename = shift;
  my $dir = shift;
  my $res = system(
      'bin\wget\wget', '-q', '--no-check-certificate',
      'https://github.com/olliw42/storm32bgc/tree/master/firmware%20binaries%20%26%20gui/'.$zipfilename.'.zip'
      );
  if( $res != 0 ){ return 0; }
  system( 'move', $zipfilename.'.zip', $dir );
  return 1;
}

# Ende # UPDATE Tool Window
###############################################################################









#-----------------------------------------------------------------------------#
###############################################################################
# NT Module CLI Tool Window
###############################################################################
#    SHARE SETTINGS Tool Window
#    CHECK NT MODULE VERSIONS Tool Window
#    CHANGE BOARD CONFIGURATION Tool Window
#    EDIT BOARD NAME Tool Window
#    GUI BAUDRATE Tool Window
#    NTLogger RTC Configuration Tool Window
#    UPDATE Tool Window
# -> NT Module CLI Tool Window
###############################################################################
#-----------------------------------------------------------------------------#

my $NtCliIsInitialized = 0;

my $NtCliTunnelIsOpen = 0;
my $NtCliTunnelIsMotor = 0;
my $NtCliTunnelIsLogger = 0;

my $NtCliBackgroundColor = [96,96,96];

my $NtCliXsize = 450; #700; #450;
my $NtCliYsize = 470 + 100;

#my $w_NtCli = Win32::GUI::DialogBox->new( -name=> 'ntcli_Window', -parent => $w_Main, -font=> $StdWinFont,
my $w_NtCli = Win32::GUI::Window->new( -name=> 'ntcli_Window', -parent => $w_Main, -font=> $StdWinFont,
  -text=> "o323BGC NT Module CLI Tool", -size=> [$NtCliXsize,$NtCliYsize],
  -helpbox => 0,
  -background=>$NtCliBackgroundColor,
  -dialogui => 1, #is required for correct ret handling
  -hasminimize => 0, -minimizebox => 0, -hasmaximize => 0, -maximizebox => 0,
);
$w_NtCli->SetIcon($Icon);


sub ntcli_Window_Resize
{
  my $mw = $w_NtCli->ScaleWidth();
  my $mh = $w_NtCli->ScaleHeight();
  $w_NtCli->ntcli_Cmd->Width( $mw - 110 );
  $w_NtCli->ntcli_Send->Left( $mw - 80 );
  $w_NtCli->ntcli_RecieveText->Width( $mw - 3 -8 );
  $w_NtCli->ntcli_RecieveText->Height( $mh - 153 -8 -65 );
}


sub ntcli_Window_Terminate
{
  $w_Main->ntcli_Timer->Kill(1);
  WritePort( '@Q' );
  _delay_ms(50);
  ClosePort();
  $w_NtCli->Hide();
  0;
}


sub NtCliInit
{
  if( $NtCliIsInitialized > 0 ){ return; }
  $NtCliIsInitialized = 1;
  my $xpos = 20;
  my $ypos = 20;
  $w_NtCli->AddLabel( -name=> 'ntcli_Text1_label', -font=> $StdWinFont,
    -text=> "Tool for accessing the CLI of NT modules.",
    -pos=> [$xpos,$ypos], -width=> 420,  -height=>30,
    -background=>$NtCliBackgroundColor, -foreground=> [255,255,255],
  );
  $ypos += 30;

  $w_NtCli->AddButton( -name=> 'ntcli_OpenIMU1', -font=> $StdWinFont,
    -text=> 'NT IMU1', -pos=> [$xpos,$ypos], -width=> 60, #-height=>24,
    -onClick=> sub{ NtCliOpenTunnel('Imu1'); }
  );
  $w_NtCli->AddButton( -name=> 'ntcli_OpenIMU2', -font=> $StdWinFont,
    -text=> 'NT IMU2', -pos=> [$xpos + 1*65,$ypos], -width=> 60,
    -onClick=> sub{ NtCliOpenTunnel('Imu2'); }
  );
  $w_NtCli->AddButton( -name=> 'ntcli_OpenPitch', -font=> $StdWinFont,
    -text=> 'NT Pitch', -pos=> [$xpos + 2*65,$ypos], -width=> 60,
    -onClick=> sub{ NtCliOpenTunnel('Motor Pitch'); }
  );
  $w_NtCli->AddButton( -name=> 'ntcli_OpenRoll', -font=> $StdWinFont,
    -text=> 'NT Roll', -pos=> [$xpos + 3*65,$ypos], -width=> 60,
    -onClick=> sub{ NtCliOpenTunnel('Motor Roll'); }
  );
  $w_NtCli->AddButton( -name=> 'ntcli_OpenYaw', -font=> $StdWinFont,
    -text=> 'NT Yaw', -pos=> [$xpos + 4*65,$ypos], -width=> 60,
    -onClick=> sub{ NtCliOpenTunnel('Motor Yaw'); }
  );
  $w_NtCli->AddButton( -name=> 'ntcli_OpenLogger', -font=> $StdWinFont,
    -text=> 'NT Logger', -pos=> [$xpos + 5*65,$ypos], -width=> 60,
    -onClick=> sub{ NtCliOpenTunnel('Logger'); }
  );

  $w_NtCli->AddButton( -name=> 'ntcli_Close', -font=> $StdWinFont,
    -text=> 'Close Tunnel', -pos=> [$xpos,$ypos+30], -width=> 100,
    -onClick=> sub{ NtCliCloseTunnel(); }
  );

  $ypos += 65 + 10;
  my $butwidth = 60;
  $w_NtCli->AddButton( -name=> 'ntcli_GetSetup', -font=> $StdWinFont,
    -text=> 'getsetup', -pos=> [$xpos + 0*($butwidth+5),$ypos], -width=> $butwidth,
    -onClick=> sub{ NtCliWriteCmd('getsetup'); }
  );
  $w_NtCli->AddButton( -name=> 'ntcli_ReadRtc', -font=> $StdWinFont,
    -text=> 'readrtc', -pos=> [$xpos + 0*($butwidth+5),$ypos], -width=> $butwidth,
    -onClick=> sub{ NtCliWriteCmd('readrtc'); }
  );
  $w_NtCli->AddButton( -name=> 'ntcli_Rrange', -font=> $StdWinFont,
    -text=> 'rrange', -pos=> [$xpos + 1*($butwidth+5),$ypos], -width=> $butwidth,
    -onClick=> sub{ NtCliWriteCmd('rrange'); }
  );
  $w_NtCli->AddButton( -name=> 'ntcli_Rpp', -font=> $StdWinFont,
    -text=> 'rpp', -pos=> [$xpos + 2*($butwidth+5),$ypos], -width=> $butwidth,
    -onClick=> sub{ NtCliWriteCmd('rpp'); }
  );
  $w_NtCli->AddButton( -name=> 'ntcli_Rofs', -font=> $StdWinFont,
    -text=> 'rofs', -pos=> [$xpos + 3*($butwidth+5),$ypos], -width=> $butwidth,
    -onClick=> sub{ NtCliWriteCmd('rofs'); }
  );
  $w_NtCli->AddButton( -name=> 'ntcli_Store', -font=> $StdWinFont,
    -text=> 'store', -pos=> [$xpos + 4*($butwidth+5),$ypos], -width=> $butwidth,
    -onClick=> sub{ NtCliWriteCmd('store'); }
  );
  $ypos += 30;
  $w_NtCli->AddButton( -name=> 'ntcli_Moveby50', -font=> $StdWinFont,
    -text=> 'moveby50', -pos=> [$xpos + 0*($butwidth+5),$ypos], -width=> $butwidth,
    -onClick=> sub{ NtCliWriteCmd('moveby 50'); }
  );
  $w_NtCli->AddButton( -name=> 'ntcli_Movebym50', -font=> $StdWinFont,
    -text=> 'moveby-50', -pos=> [$xpos + 1*($butwidth+5),$ypos], -width=> $butwidth,
    -onClick=> sub{ NtCliWriteCmd('moveby -50'); }
  );
  $w_NtCli->AddButton( -name=> 'ntcli_R2ppofs', -font=> $StdWinFont,
    -text=> 'r2ppofs', -pos=> [$xpos + 2*($butwidth+5),$ypos], -width=> $butwidth,
    -onClick=> sub{ NtCliWriteCmd('r2ppofs'); }
  );

  $xpos = 20;
  $ypos += 65 +10 -30-10;
  $w_NtCli->AddTextfield( -name=> 'ntcli_Cmd', -font=> $StdWinFont,
    -pos=> [$xpos,$ypos-3],
    -size=> [$NtCliXsize-157-4+46,23],
  );
  $w_NtCli->AddButton( -name=> 'ntcli_Send', -font=> $StdWinFont,
    -text=> 'Send', -pos=> [$NtCliXsize-90,$ypos-3+2], -width=> 60,
    -ok => 1,
  );

  $ypos += 30;
  $w_NtCli->ntcli_Cmd->Text('');
  $w_NtCli-> AddTextfield( -name=> 'ntcli_RecieveText',
    -pos=> [5,$ypos], -font=> $StdTextFont,
    -vscroll=> 1, -multiline=> 1, -readonly => 1,
    -foreground =>[ 0, 0, 0],
    -background=> [192,192,192],#[96,96,96],
  );

  $NtCliTunnelIsOpen = 0;
} #end of NtCliInit()


sub NtCliSetToTunnelIsOpen
{
my $module = shift;
  $NtCliTunnelIsOpen = 1;
  if( $module =~ /Motor/ ){ $NtCliTunnelIsMotor = 1; }else{ $NtCliTunnelIsMotor = 0; }
  if( $module =~ /Logger/ ){ $NtCliTunnelIsLogger = 1; }else{ $NtCliTunnelIsLogger = 0; }

  $w_NtCli->ntcli_OpenIMU1->Disable();
  $w_NtCli->ntcli_OpenIMU2->Disable();
  $w_NtCli->ntcli_OpenPitch->Disable();
  $w_NtCli->ntcli_OpenRoll->Disable();
  $w_NtCli->ntcli_OpenYaw->Disable();
  $w_NtCli->ntcli_OpenLogger->Disable();
  $w_NtCli->ntcli_Close->Enable();

  if( $NtCliTunnelIsLogger ){
    $w_NtCli->ntcli_GetSetup->Hide();
    $w_NtCli->ntcli_GetSetup->Disable();
    $w_NtCli->ntcli_ReadRtc->Show();
    $w_NtCli->ntcli_ReadRtc->Enable();
    $w_NtCli->ntcli_Store->Disable();
  } else {
    $w_NtCli->ntcli_GetSetup->Enable();
    $w_NtCli->ntcli_Store->Enable();
  }
  if( $NtCliTunnelIsMotor ){
    $w_NtCli->ntcli_Rrange->Enable();
    $w_NtCli->ntcli_Rpp->Enable();
    $w_NtCli->ntcli_Rofs->Enable();
    $w_NtCli->ntcli_Moveby50->Enable();
    $w_NtCli->ntcli_Movebym50->Enable();
    $w_NtCli->ntcli_R2ppofs->Enable();
  }
}

sub NtCliSetToTunnelIsClosed
{
  $NtCliTunnelIsOpen = 0;
  $NtCliTunnelIsMotor = 0;
  $NtCliTunnelIsLogger = 0;
  $w_NtCli->ntcli_OpenIMU1->Enable();
  $w_NtCli->ntcli_OpenIMU2->Enable();
  $w_NtCli->ntcli_OpenPitch->Enable();
  $w_NtCli->ntcli_OpenRoll->Enable();
  $w_NtCli->ntcli_OpenYaw->Enable();
  $w_NtCli->ntcli_OpenLogger->Enable();
  $w_NtCli->ntcli_Close->Disable();

  $w_NtCli->ntcli_ReadRtc->Hide();
  $w_NtCli->ntcli_ReadRtc->Disable();
  $w_NtCli->ntcli_GetSetup->Show();
  $w_NtCli->ntcli_GetSetup->Disable();
  $w_NtCli->ntcli_Rrange->Disable();
  $w_NtCli->ntcli_Rpp->Disable();
  $w_NtCli->ntcli_Rofs->Disable();
  $w_NtCli->ntcli_Store->Disable();
  $w_NtCli->ntcli_Moveby50->Disable();
  $w_NtCli->ntcli_Movebym50->Disable();
  $w_NtCli->ntcli_R2ppofs->Disable();
}

sub NtCliShow
{
  if( ConnectionIsValid() ){
    DisconnectFromBoard(0); ##it disconnects itself then UARTis removed
  }
  if( not OpenPort() ){ ClosePort(); TextOut( "\n".'NT Module Cli Tool... ABORTED!'."\n" ); return; }
  my ($x, $y) = ($w_Main->GetWindowRect())[0..1];
  $w_NtCli->Move($x+150,$y+100  -70);
  $w_NtCli->ntcli_RecieveText->Text('');
  NtCliSetToTunnelIsClosed();
  $w_NtCli->Show();

  $w_Main->AddTimer( 'ntcli_Timer', 50 ); #every 50ms
}


sub ntcli_Timer_Timer
{
  my $response = ''; my $i = 0; my $s = '';
  do{
    ($i, $s) = ReadPortOneByte();
    if( $i > 0 ){
      my $ss = NtCliStrToReadableStr($s);
      $response .= $ss;
    }
  }while( $i > 0 );
  if( $response ne '' ){ NtCliTextOut($response); }
}


sub ntcli_Send_Click
{
  my $cmd = $w_NtCli->ntcli_Cmd->Text();
  if( $NtCliTunnelIsOpen ){
    if( substr($cmd,-1) ne ';' ){ $cmd .= ";"; } #this can only be done when tunnel is open
  }
  WritePort( $cmd );
  $w_NtCli->ntcli_Cmd->Text('');
  0;
}


sub NtCliTextOut
{
  $w_NtCli->ntcli_RecieveText->Append( PrepareTextForAppend(shift) );
}


sub NtCliStrToReadableStr{
  my $s = shift;
  my $ss = '';
  for(my $i=0; $i<length($s); $i+=1 ){
    my $c = ord( substr($s,$i,1) );
    if( ($c >= ord(' ')) and ($c <= ord('~')) ){
      $ss .= chr($c);
    }elsif( $c == 10 ){
      $ss .= "\n";
    }elsif( $c == 13 ){
    }else{
      $ss .= '.';
    }
  }
  return $ss;
}


my $NtCliCmdTimeOut = 20;


sub NtCliOpenTunnel
{
my $module = shift;
  my ($id,$id2) = NtModuleNameToId($module);
  NtCliTextOut( "\n".'open tunnel to '.$module.'... ' );
#  WritePort('xQTcNTQMODE'.$IDstr);
  my $s = ExecuteCmd( 'xQ' );
  if( substr($s,length($s)-1,1) ne 'o' ){
    NtCliSetToTunnelIsClosed();
    NtCliTextOut( "\n".'open tunnel ... FAILED!'."\n" );
    return 0;
  }
  WritePort('TcNTQMODE'.$id2);
  #wait for a response with a 'Hello'
  my $count = 0; my $result = '';
  my $tmo = GetTickCount() + 150*$NtCliCmdTimeOut;
  while( GetTickCount() < $tmo  ){
    my ($i, $s) = ReadPortOneByte();
    $count += $i;
    $result .= $s;
    Win32::GUI::DoEvents();
    if( substr($result,-5) eq 'Hello' ){ last; }
  };
  if( substr($result,-5) ne 'Hello' ){
    WritePort('@Q'); #we need to send this to bring back the STorM32 controller
    NtCliSetToTunnelIsClosed();
    NtCliTextOut( "\n".'open tunnel ... FAILED!'."\n" );
    return 0;
  }
  #probably all good
  NtCliTextOut( 'ok'."\n" );
  NtCliTextOut($result);
  NtCliSetToTunnelIsOpen($module);
  return 1;
}


sub NtCliCloseTunnel
{
  WritePort('@Q');
  NtCliTextOut( "\n".'wait... ' );
  _delay_ms(1000);
  NtCliTextOut( "\n".'tunnel closed'."\n\n" );
  NtCliSetToTunnelIsClosed();
  return 1;
}


sub NtCliWriteCmd
{
  my $cmd = shift;
  if( substr($cmd,-1) ne ';' ){ $cmd .= ";"; }
  WritePort( $cmd );
  return 1;
}



# Ende # BNT MODULE CLI Tool Window
###############################################################################
