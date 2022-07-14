source("../R/java_hashCode.R")

message("* java_hashCode() ...")

hash <- java_hashCode("")
print(hash)
stopifnot(hash == 0)

hash <- java_hashCode("A")
print(hash)
stopifnot(hash == 65)

hash <- java_hashCode("alice,rstudio")
print(hash)
stopifnot(hash == -606348900)

hash <- java_hashCode("port4me - get the same, personal, free TCP port over and over")
stopifnot(hash == 1731535982)

message("* java_hashCode() ... done")
