title: Avoiding anti-patterns in Ruby - Arrays
updated: 21/Mar/2012 14:50
###

Since I came to Ruby from the Java and PHP world I found many expresions
used in Ruby cryptic and I was trying to avoid them in my daily life.
After years and thousand lines of Ruby code I red I feel a need to change
the way how I write the code. I want to make my code look better, readable
and preferably optimized.

> In software engineering, an anti-pattern (or antipattern) is a pattern that
> may be commonly used but is ineffective and/or counterproductive in practice.
> [wikipedia](http://en.wikipedia.org/wiki/Anti-pattern)

For, each or map?
-----------------

Iteration is the perfect example what I should improve. When I started writing
ruby code, I was used to write this:

<script src="https://gist.github.com/2147039.js?file=gistfile1.rb"></script>

This syntactically perfect Ruby code. Also for PHP/Java newcomers it also looks
perfectly valid. However, it's not what rest of the Ruby programmers usually
write. As you may already know, Ruby is object-oriented language and `[]` in
Ruby is just an alias for the `Array.new`. If you look to the [Array](http://www.ruby-doc.org/core-1.9.3/Array.html)
class documentation, you will find many interesting methods, like:

**`.each`**

The each method can be used for iterating the Array in case you don't want to
return anything from the iteration block:

<pre class="sh_ruby">
  [1,2,3].each { |i| i+1 }
  # => [1,2,3]
</pre>

This method is good if you want modify some object outside the iteration block,
or just call some method without caring to much about what the method return,
like:

<pre class="sh_ruby">
  [inst1, inst2, inst3].each { |i| i.stop! }
</pre>

**`.map`**

There are cases when you want to modify the content of an Array. In PHP you
usually do a clone of the Array or create a new array with updated items. In
Ruby this is not necessary:

<pre class="sh_ruby">
  a = [1,2,3]
  b = []
  a.each { |i| b.add(i+2) }
  # b => [2, 4, 5] 
</pre>

As you may feel, there are few glithes in this code. First, you create a new
variable (mean you allocate space for it). In many cases you also left the
variable `a` abandoned, stealing quietly your memory. The right Ruby approach
would be here:

<pre class="sh_ruby">
  a = [1,2,3]
  a.map { |i| i+1 } # => [2, 4, 5]
</pre>

The `map` method here will iterate through array and give you change to modify
the content of it. Then it will return the modified Array back to you.

**`.any?`**

Next anti-pattern commonly seen in Ruby world is to use `.each` to iterate
though the array and return boolean when it found a match:

<pre class="sh_ruby">
  a = [1,2,3]
  a.each do |i|
    return true if i == 2
  end
</pre>

The correct Ruby approach here would be to use the `any?` method to search the
array:

<pre class="sh_ruby">
  a = [1,2,3]
  a.any? { |i| i == 2 } # => true
</pre>

Please note that for the example above, the `any?` method is an overkill. This
method can be replaced by `.include?(2)` in this case. The main point of this
example was to show you that you can do more complicated checking using the
`any?` method instead of over-using the `.each`.

The ultimate main goal of every Ruby programmer, who care about the code he is
writing is to make the reader of his code undestand what the author is trying to
say (without using comments). Ruby offers many 'syntax' sugar methods to achieve
this goal. For example:

<pre class="sh_ruby">
  a = [1,2,3]
  a.reject { |i| i == 2 } # => [1, 3]
  a.keep_if { |i| [1,2].include?(i) } # => [1, 2]
  a.find { |i| i == 2 } # => 2
</pre>
