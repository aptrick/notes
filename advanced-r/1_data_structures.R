# ==============================================================================
# DATA STRUCTURES
#
# http://adv-r.had.co.nz/Data-structures.html
# ==============================================================================

# Base data structures can be organized by their dimensionality (1d, 2d, or nd)
# and whether or not they're homogenous (i.e., all contents must be of the same
# type):
#
#   Atomic vector: 1d homogenous
#   List: 1d heterogenous
#   Matrix: 2d homogenous
#   Data frame: 2d heterogenous
#   Array: nd homogenous

# Best way to understand data structures is to use str():
str(1:10)
str(data.frame())
str(list())

# ==============================================================================
# VECTORS

# Basic data structure. Has three important properties:
#   1. Type, what it is
#   2. Length, how many elements it has
#   3. Attributes, additional arbitrary metadata
x <- rnorm(50)
typeof(x)
length(x)
attributes(x)
attr(x, "name") <- "normal sample"
attributes(x)

# Types of atomic vectors:
#   Logical
#   Integer
#   Double (numeric)
#   Character
#   Complex (RARE)
#   Raw (RARE)

# Missing values are specified with NA, a logical vector of length 1. However,
# NA will be coerced to the correct type if used within c(). You can also create
# NAs of a specific type:
typeof(NA)            # logical
typeof(NA_real_)      # double
typeof(NA_integer_)   # integer
typeof(NA_character_) # character

# You can use various "is" functions to test for a vector's type:
ints <- c(1L, 2L, 3L)
is.integer(ints)   # TRUE
is.atomic(ints)    # TRUE
is.double(ints)    # FALSE
is.logical(ints)   # FALSE
is.character(ints) # FALSE

# is.numeric() returns TRUE for both integer and double vectors.

# Coercion: when you attempt to combine different types in an atomic vector,
# they will be coerced to the most flexible type. Order of flexibility:
# character, double, integer, logical.
c(FALSE, "hi", 5, 6L)
# [1] "FALSE" "hi"    "5"     "6"

# You can explicitly coerce with as.character(), as.double(), as.integer(),
# as.numeric(), or as.logical().

# ==============================================================================
# LISTS

# Differ from vectors in that they can contain elements of multiple types.

# list() : lists :: c() : vectors
x <- list(1:3, "a", c(TRUE, FALSE, TRUE), c(2.3, 5.9))
str(x)

# Lists can also contain other lists:
x <- list(list(list()))
str(x)

# c() will combine several lists into one:
c(list(1), list(2))

# is.list() tests if something is a list:
is.list(list())

# as.list() coerces something to a list:
as.list(1:10)

# You can turn a list into an atomic vector with unlist(). unlist() uses
# same coercion rules as c().
unlist(as.list(1:10))

# Lists are used to build up many of the more complicated data structures in R,
# like data frames and the linear model objects.

# ==============================================================================
# ATTRIBUTES

# All objects can have additional arbitrary attributes. These can be thought of
# as a named list.
y <- 1:10
attr(y, "my_attribute") <- "This is a vector"
attr(y, "my_attribute")
str(attributes(y))

# The structure() function can be used to add attributes to an object:
structure(y, name = "My Vector")

# Most attributes are lost when a vector is modified:
attributes(c(y, 1))  # NULL
attributes(sum(y))   # NULL

# The only attributes that are NOT lost are the three most important ones:
#   Names: a character vector giving each element a name
#   Dimensions: used to turn vectors into arrays and matrices
#   Class: used to implement the S3 class system

# Three ways to name a vector:
#   When creating it:
x <- c(a = 1, b = 2)
#   Using names():
x <- 1:2
names(x) <- c("a", "b")
#   By creating a modified copy of a vector:
x <- setNames(1:2, c("a", "b"))

# ==============================================================================
# FACTORS

# A factor is a vector that can only contain predefined values ("levels") and is
# used to store categorical data.

# Built on top of integer vectors using two attributes:
#   the class(), factor
#   the levels(), which defines the set of allowed values

x <- factor(c("a", "b", "b", "a"))
typeof(x)
class(x)

# You can't use values that are not in the levels:
x[2] <- "c"

# You can't combine factors:
x <- c(factor("a"), factor("b"))
x
typeof(x)
class(x)

# Using a factor rather than a character vector makes it obvious when a group
# contains no observations:
sex.char <- c("m", "m", "m")
sex.factor <- factor(sex.char, levels = c("m", "f"))

table(sex.factor)
# sex.factor
# m f
# 3 0

# Most data loading functions automatically convert character vectors to
# factors. When loading data, use the argument stringsAsFactors = FALSE to
# prevent this.

# ==============================================================================
# MATRICES AND ARRAYS

# Adding a dim() attribute to an atomic vector allows it to behave like a
# multi-dimensional array.

a <- matrix(1:6, ncol = 3, nrow = 2)
b <- array(1:12, c(2, 3, 2))

a <- 1:6
dim(a) <- c(3, 2)

b <- 1:12
dim(b) <- c(2, 3, 2)

# names() generalizes to dimnames() in higher dimensions:
dimnames(b) <- list(c("one", "two"), c("a", "b", "c"), c("A", "B"))

# c() generalizes to cbind() and rbind() for matrices and abind() for arrays:
library(abind)
abind(b, b)

# You can transpose a matrix with t():
t(a)

# You can also use dim() to create "list-matrices" and "list-arrays", though
# these are relatively rare:
l <- list(1:3, "a", TRUE, 1.0)
dim(l) <- c(2, 2)

# ==============================================================================
# DATA FRAMES

# Most common way of storing data in R.

# Under the hood, a data frame is a LIST OF EQUAL-LENGTH VECTORS.

# names(df) == colnames(df)
# length(df) == ncol(df)

# By default, data.frame() converts strings to factors. Use stringsAsFactors =
# FALSE to suppress this.

# The type of a data frame is a list:
df <- data.frame(x = 1:5, y = 6:10)
class(df)   # data.frame
typeof(df)  # list

# Coercion:
as.data.frame(list(1, 1:3))

# Since a data frame is a list of vectors, it can have a column that is a list:
df <- data.frame(x = 1:3)
df$y <- list(1:2, 1:3, 1:4)
df

# This can be dangerous, though, since some functions assume all columns are
# atomic vectors.

# Note that you get an error if you try to assign a list to a column in the
# data.frame() function:
data.frame(x = 1:3, y = list(1:2, 1:3, 1:4))

# As a workaround, you can wrap the list in the I() function:
data.frame(x = 1:3, y = I(list(1:2, 1:3, 1:4)))

# The I() function adds the "AsIs" class to an object to indicate that it should
# be treated as is. This has two main uses:
#   In data.frame(), it allows lists/matrices to be inserted as single columns.
#   In formula(), it inhibits the interpretation of operators like "+" as
#      formula operators, so that they're used as arithmetical operators
#      instead.
x <- rnorm(10)
y <- rnorm(10)
z <- x + y + rnorm(10)

# Compare:
lm(z ~ x + y)
lm(z ~ I(x + y))

# What attributes does a data frame possess?
#   1. names
#   2. row.names
#   3. class (data.frame)
