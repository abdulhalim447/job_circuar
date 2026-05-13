void main() {
  String text = '''<h6 class="gb-headline gb-headline-01e810c0 gb-headline-text"><strong>এই মাত্র</strong> <strong>প্রকাশিত নিয়োগ বিজ্ঞপ্তি গুলো পড়তে পারেন</strong>!</h6>
<ul class="wp-block-latest-posts__list is-grid columns-2 wp-block-latest-posts"><li>hello</li></ul><hr />''';

  final relatedPostsRegex = RegExp(
    r'<h6[^>]*>.*?এই মাত্র.*?প্রকাশিত নিয়োগ বিজ্ঞপ্তি.*?</h6>\s*<ul[^>]*wp-block-latest-posts[^>]*>.*?</ul>\s*(<hr[^>]*>)?',
    dotAll: true,
  );
  
  print(relatedPostsRegex.hasMatch(text));
  print(text.replaceAll(relatedPostsRegex, ''));
}
