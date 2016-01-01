# avidemux_helper_per_1file.pl

SJ4000(のコピー品)で録画したMovieをdemux→mp4にmuxするスクリプト。
元々がQuickTimeでAVIutlで扱いにくいために作成。

以下のようなBatchを作成しておくことで、D&Dでdemux→muxできる。


```
cd /d %~dp0
perl avidemux_helper_per_1file.pl %*
```
