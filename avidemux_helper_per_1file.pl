use strict;
use warnings;
use utf8;
use Encode;
use File::Find;
use File::Basename;
use File::Copy;
use Path::Tiny;


my $cp932 = Encode::find_encoding("cp932");
my $avidemux = 'C:\Program Files\Avidemux 2.6 - 64 bits\avidemux_cli.exe';
my $scr = Path::Tiny->tempfile;


if (@ARGV == 0) {
    printf $cp932->encode(<<HELP);
SJ4000で録画したMovieをmp4にdemuxする
(AVIUtl等で扱いやすくするため)

usage : $0  INPUT_1.mov  INPUT_2.mov ...

HELP
    exit;
}

my @inputs = map {s#\\#\/#g; $_} sort @ARGV;

foreach my $in (@inputs) {
    demux($in);
}


sub demux {
    my @in = @_;
    # avidemux scriptを作成
    my $load_and_append = join "\n", qq'adm.loadVideo("$in[0]")', map {qq'adm.appendVideo("$_")'} @in[1 .. $#in];

    my $template = <<TEMPLATE;
#PY  <- Needed to identify #
#--automatically built--

adm = Avidemux()
$load_and_append
adm.videoCodec("Copy")
adm.audioClearTracks()
adm.setSourceTrackLanguage(0,"unknown")
adm.audioAddTrack(0)
adm.audioCodec(0, "Faac");
adm.audioSetDrc(0, 0)
adm.audioSetShift(0, 0,0)
adm.setContainer("MP4", "muxerType=0", "useAlternateMp3Tag=True")
TEMPLATE


    open my $wfh, ">", $scr or die $!;
    print $wfh $template;
    close $wfh;


    # avidemuxで出力
    my $target = path('.') . '/' . File::Basename::basename($in[0]) . ".mp4";
    my $cmd = qq'"$avidemux" --run $scr --save $target';
    printf "%s\n", $cmd;
    system $cmd;


    # 完了したファイルをdoneフォルダに移動
    #my $done_dir = sprintf "%s/done", File::Basename::dirname($in[0]);
    #my $done_dir = sprintf "%s/done", ".";
    #if (not -d $done_dir) {
    #    mkdir $done_dir;
    #}

    #foreach my $input (@in) {
    #    move($input, $done_dir);
    #}
}





__END__
 Command line possible arguments :
    --nogui, Run in silent mode  ( no arg )
    --slave, run as slave, master is on port arg  (one arg )
    --run, load and run a script  (one arg )
    --save-jpg, save a jpeg  (one arg )
    --begin, set start frame  (one arg )
    --end, set end frame  (one arg )
    --save-raw-audio, save audio as-is   (one arg )
    --save-uncompressed-audio, save uncompressed audio  (one arg )
    --load, load video or workbench  (one arg )
    --load-workbench, load workbench file  (one arg )
    --append, append video  (one arg )
    --save, save avi  (one arg )
    --force-b-frame, Force detection of bframe in next loaded file  ( no arg )
    --force-alt-h264, Force use of alternate read mode for h264  ( no arg )
    --external-audio, Load an external audio file. {track_index} {filename}  (two args )
    --set-audio-language, Set language of an active audio track {track_index} {language_short_name}  (two args )
    --audio-delay, set audio time shift in ms (+ or -)  (one arg )
    --audio-codec, set audio codec (MP2/MP3/AC3/NONE (WAV PCM)/TWOLAME/COPY)  (one arg )
    --video-codec, set video codec (Divx/Xvid/FFmpeg4/VCD/SVCD/DVD/XVCD/XSVCD/COPY)  (one arg )
    --video-conf, set video codec conf (cq=q|cbr=br|2pass=size)[,mbr=br][,matrix=(0|1|2|3)]  (one arg )
    --reuse-2pass-log, reuse 2pass logfile if it exists  ( no arg )
    --autosplit, split every N MBytes  (one arg )
    --info, show information about loaded video and audio streams  ( no arg )
    --output-format, set output format (AVI|OGM|ES|PS|AVI_DUAL|AVI_UNP|...)  (one arg )
    --rebuild-index, rebuild index with correct frame type  ( no arg )
    --var, set var (--var myvar=3)  (one arg )
    --help, print this  ( no arg )
    --quit, exit avidemux  ( no arg )
    --probePat, Probe for PAT//PMT..  (one arg )
    --list-audio-languages, list all available audio langues  ( no arg )
    --avisynth-port, set avsproxy port accordingly  (one arg )
