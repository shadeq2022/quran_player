String formatDuration(Duration duration) {
  final safeDuration = duration < Duration.zero ? Duration.zero : duration;
  final minutes = safeDuration.inMinutes.remainder(100).toString().padLeft(2, '0');
  final seconds = safeDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
