title: Avoiding anti-patterns in Ruby - Arrays
updated: 21/Mar/2012 14:50
###

Since I came to Ruby from the Java and PHP world I found many expressions
used in Ruby cryptic and I was trying to avoid them in my daily life.
After years and thousand lines of Ruby code I've red I feel a need to change
the way how I write the code. I want to make my code look better, readable
and preferably save keystrokes.

> In software engineering, an anti-pattern (or antipattern) is a pattern that
> may be commonly used but is ineffective and/or counterproductive in practice.
> [wikipedia](http://en.wikipedia.org/wiki/Anti-pattern)

For, each or map?
-----------------

Iteration is the perfect example what I should improve. When I started writing
the Ruby code, I was used to write constructions like this:

<pre class="sh_ruby">
  fruits = ['apple', 'cherry', 'peach', 'orange']

  for fruit in fruits do
    puts fruit
  end
</pre>

This syntactically perfect Ruby code. Also for PHP/Java newcomers it also looks
perfectly safe. However, it's not what rest of the Ruby programmers usually
write. As you may already know, Ruby is object-oriented language and `[]` in
Ruby is just an alias for the `Array.new`. If you look to the [Array](http://www.ruby-doc.org/core-1.9.3/Array.html)
class documentation, you will find many interesting methods, I want to describe
below:

**`.each`**

The each method can be used for iterating the Array in case you don't want to
return anything from the iteration block:

<pre class="sh_ruby">
  [1,2,3].each { |i| i+1 }
  # => [1,2,3]
</pre>

This method is good if you want modify some object outside the iteration block,
or just call some method without caring to much about what the method returns,
like:

<pre class="sh_ruby">
  [inst1, inst2, inst3].each { |i| i.stop! }
</pre>

For example, you can create an alias in Array for `.each`:

<pre class="sh_ruby">
  class Array
    alias_method :each_instance, :each
  end

  [inst1, inst2, inst3].each_instance { |instance| instance.stop! }
</pre>

This will immediately yell on you what this code is trying to do.
Please do not use this method for changing the content of variables or creating
a new arrays.

In most cases the `.each` method can be replaced with some of the
methods bellow:

**`.map`**

There are cases when you want to modify the content of an Array. And return the
modified content. In PHP you usually do a clone of the Array or create a new array
with updated items. In Ruby this is not necessary:

<pre class="sh_ruby">
  a = [1,2,3,4,5]
  result = []
  a.each do |i|
    result << i+1
  end
  result # => [2,3,4,5,6]
</pre>

As you may guess, there are few glitches in this code. First, you create a new
variable (mean you allocate space for it). In many cases you also left the
variable `a` abandoned, stealing quietly your memory. The right Ruby approach
the `.map` method will be used:

<pre class="sh_ruby">
  a = [1,2,3]
  a.map { |i| i+1 } # => [2, 4, 5]
</pre>

The `.map` method here will iterate through array and give you chance to modify
the content of it. Then it will return the modified Array back to you, but keep
the original content of `a` variable untouched.
If you don't want to return anything but instead modify the original array instead,
just use the `.map!` method:

<pre class="sh_ruby">
  a = [1,2,3]
  a.map! { |i| i+1 }
  puts a.inspect # => [2, 4, 5]
</pre>

**`.any?`**

Next anti-pattern commonly seen in Ruby newcomers world is to use `.each` to iterate
though the Array and return boolean when it found a match:

<pre class="sh_ruby">
  def find_odd_number(arr)
    arr.each do |i|
      return true unless i.odd?
    end
  end
</pre>

Please keep in mind that the `return` statement is used **only** for returning
from a method or Proc/lambda. And your should then have this statement in
context if this method, not in context of `.each` block.
The correct Ruby approach here would be to use the `any?` method to search the
array:

<pre class="sh_ruby">
  def find_odd_number(arr)
    arr.any? { |i| !i.odd? }
  end
</pre>

The example above will return true if there is an odd number in the array. No
need to write over-complicated `.each` iterations.

The ultimate main goal of every Ruby programmer, who care about the code he is
writing is to make the reader of his code understand what the author is trying to
say (without using comments). Ruby offers many 'syntax' sugar methods to achieve
this goal. For example:

<pre class="sh_ruby">
  a = [1,2,3]
  a.reject { |i| i == 2 } # => [1, 3]
  a.keep_if { |i| [1,2].include?(i) } # => [1, 2]
  a.find { |i| i == 2 } # => 2
</pre>

As you may see, Ruby is trying to be very descriptive for the reader, so you
don't need to read too much code to get a clue what the code is trying to do.

There are many [aliases](http://ruby.about.com/od/rubyfeatures/a/aliasing.htm)
that can help you to make your code more readable. For example the
[`.index`](http://www.ruby-doc.org/core-1.9.3/Array.html#method-i-index) method,
that will return a position of the element inside the Array is just an alias for
the `.find_index` method. If it makes your code more readable, you're free to use
this alias instead of the original method.

In Ruby Array class you can find more handy aliases. For example if you want to
access first or last item of the array, you can think about writing this:

<pre class="sh_ruby">
  a = [ 'a', 'b', 'c', 'd' ]
  puts a[0] # => 'a'
  puts a[a.size-1] # => 'd'
</pre>

Since the indexing of arrays in Ruby starting from zero, the programmer may know
that you're trying to access first element. But why to make people think about
indexing numbers? For example, you can use the `.first` method in Array to
retrieve the first item. In this case, it doesn't really matter what is the
index number of first element:

<pre class="sh_ruby">
  a = [ 'a', 'b', 'c', 'd' ]
  puts a.first # => 'a'
</pre>

The same thing apply for the last item in array. As you might see in the first
example, the calculation is quite strange and it does not yell on you that you
want to return last element. So there is a `.last` method that will hide this
calculation for you and yell on reader that you want to access the last element.

So a quick summary:

* Use `.each` method only when you're not modifying any variable in current
  context. Modifying the state of object using exclamation mark methods is
  perfect use-case for this.

* Use `.map` when you need to modify content of variable or return a modified
  version of the array. This method has also an alias `.select`. Use it if it
  makes your code more readable.

* Use `.any?` when you're searching for an item in the array that match to
  condition. If you're doing a simple search, you can also use `.include?`

* Look to the Array docs every time you're doing something nasty with `.each`.
  There will be always method that will do better job with less amount of code.

* Try to avoid accessing elements in array using the array index. If you want to
  get last or first item, there is an helper for that.
