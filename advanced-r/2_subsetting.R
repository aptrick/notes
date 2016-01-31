# ==============================================================================
# SUBSETTING
#
# http://adv-r.had.co.nz/Subsetting.html
# ==============================================================================

# ==============================================================================
# DATA TYPES

# Atomic vectors
#   Zero returns a zero-length vector:
x <- 1:5
x[0]

# Lists
#   Using [ will always return a list; [[ and $ will pull out components of a
#   list.
x <- list(1:10)
class(x[1])    # list
class(x[[1]])  # integer

# You can subset matrices and arrays in three ways:
#   with multiple vectors
#   with a single vector
#   with a matrix

# Blank subsetting lets you keep all rows and or all columns.

# [ will simplify results to lowest possible dimensionality.

# Two additional methods for S4 objects: @ (equivalent to $) and slot().

# ==============================================================================
# SUBSETTING OPERATORS

# [[ pulls out pieces of a list; can only return a single value.
x <- list(1, 2, 3)
x[[1]]
x[[1:2]]    # Error in x[[1:2]] : subscript out of bounds

# "If list x is a train carrying objects, then x[[5]] is the object in car 5;
#  x[4:6] is a train of cars 4-6."

# If you DO supply a vector it indexes recursively:
x <- list(list(1, 2))
x[[1:2]]   # 2...very unintuitive

# $ is a shorthand for [[ combined with character subsetting.
x <- list(a = 3)
x[["a"]]
x$a

# You can use [[ to extract a column from a data frame.

# S3 and S4 objects can override the standard behavior of [ and [[.

# Simplifying vs. preserving subsettings:
#   - Simplifying subsets return the simplest possible data structure that can
#     represent the output.
#   - Preserving subsets keep the structure of the input.

# Vectors
x <- c(a = 1, b = 2)
x[[1]]  # Simplifying -- removes names
x[1]    # Preserving -- keeps names

# Lists
x <- list(a = 1, b = 2)
x[[1]]  # Simplifying
x[1]    # Preserving

# Factors
x <- factor(c("a", "a", "b"))
x[1:2, drop = TRUE]  # Simplifying -- drops level b
x[1:2]               # Preserving

# Array
x <- matrix(1:16, nrow = 4)
x[1, ]                # Simplifying -- returns a vector
x[1, , drop = FALSE]  # Preserving -- returns a one-row matrix

# Data frame
mtcars[, 1]                # Simplifying -- returns a vector
mtcars[, 1, drop = FALSE]  # Preserving -- returns a data frame

# x$y is equivalent to x[["y", exact = FALSE]].
# One difference: $ does partial matching.
x <- list(abc = 1)
x$a       # 1
x[["a"]]  # NULL

# To prevent this behavior, set:
options(warnPartialMatchDollar = TRUE)

# ==============================================================================
# SUBSETTING AND ASSIGNMENT

# No checking for duplicate indices:
x <- 1:5
x[c(1, 1)] <- 2:3
x  # [1] 3 2 3 4 5

# You can't combine integer indices with NA. This raises an error:
x[c(1, NA)] <- c(1, 2)

# But you CAN combine logical indices with NA. This is useful when conditionally
# modifying vectors:
df <- data.frame(a = c(1, 10, NA))
df$a[df$a < 5] <- 0
df$a

# Subsetting with nothing can be useful because it will preserve the original
# object class and structure.
mtcars[] <- lapply(mtcars, as.integer)  # mtcars remain a data.frame
mtcars <- lapply(mtcars, as.integer)    # mtcars becomes a list

# You can use NULL to remove elements from a list:
x <- list(a = 1, b = 2)
x[["b"]] <- NULL
str(x)

# To add a literal NULL to a list, use [ and list(NULL):
y <- list(a = 1)
y["b"] <- list(NULL)
str(y)

# ==============================================================================
# APPLICATIONS

## Lookup tables (character subsetting)
x <- c("m", "f", "u", "f", "f", "m", "m")
lookup <- c(m = "Male", f = "Female", u = NA)
unname(lookup[x])

## Matching and merging by hand
grades <- c(1, 2, 2, 3, 1)

info <- data.frame(
  grade = 3:1,
  desc = c("Excellent", "Good", "Poor"),
  fail = c(F, F, T)
)

# Using match:
info[match(grades, info$grade), ]

# Using rownames:
rownames(info) <- info$grade
info[as.character(grades), ]

# gl() generates factors by specifying the pattern of their labels:
a <- gl(2, 4, 8)
b <- gl(2, 2, 8, labels = c("ctrl", "treat"))

# interaction() computes a factor which represents the interaction of the
# given factors:
interaction(a, b)
interaction(a, b, sep = " : ")

## Random samples/bootstrap
# Select 6 bootstrap replicates:
df[sample(nrow(df), 6, rep = TRUE), ]

## Ordering (integer subsetting)
# order() takes a vector and returns an integer vector describing how the
# subsetted vector should be ordered:
x <- c("b", "c", "a")
order(x)
x[order(x)]  # equivalent to sort(x) here

# By default, missing values are put at the end, but you can also remove them
# (with na.list = NA) or put them in front (with na.last = FALSE).

# Using order() to sort a data frame by a column:
df[order(df$x), ]

## Expanding aggregated counts (integer subsetting)
# Suppose you have a data frame where identical rows are collapsed into one,
# and a count column has been added. You can uncollapse it using rep():
df <- data.frame(x = c(2, 4, 1), y = c(9, 11, 6), n = c(3, 5, 1))
rep(1:nrow(df), df$n)
df[rep(1:nrow(df), df$n), ]

## Removing columns from data frames (character subsetting)
# Two ways to do this:
#   - Set individual columns to NULL
df <- data.frame(x = 1:3, y = 3:1, z = letters[1:3])
df$z <- NULL
#   - Using character subsetting:
df[setdiff(names(df), "z")]

# ==============================================================================
# EXERCISES

# Implement your own function that extracts the diagonal entries from a matrix
# (it should behave like diag(x) where x is a matrix).
diag2 <- function(m) m[seq(1, length(m), nrow(m) + 1)]

# Given a linear model, e.g., mod <- lm(mpg ~ wt, data = mtcars), extract the
# residual degrees of freedom. Extract the R squared from the model summary
# (summary(mod)).
mod <- lm(mpg ~ wt, data = mtcars)
mod$df.residual
summary(mod)$r.squared

# How would you randomly permute the columns of a data frame?
permute.cols <- function(df) df[sample(1:ncol(df))]

# How could you put the columns of a data frame in alphabetical order?
df[order(names(df))]

# How would you select a contiguous random sample of rows from a data frame?
contig.sample <- function(df, size = 1) {
  size <- min(size, nrow(df))
  start <- sample(1:(nrow(df) - size + 1), 1)
  df[start:(start + size), ]
}
