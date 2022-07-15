source("../R/java_hashCode.R")

message("* string_to_uint32() ...")

hash <- string_to_uint32("")
print(hash)
stopifnot(hash == 0)

hash <- string_to_uint32("A")
print(hash)
stopifnot(hash == 65)

hash <- string_to_uint32("alice,rstudio")
print(hash)
stopifnot(hash == 3688618396)

hash <- string_to_uint32("port4me - get the same, personal, free TCP port over and over")
stopifnot(hash == 1731535982)

message("* string_to_uint32() ... done")
