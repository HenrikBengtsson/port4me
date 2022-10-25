string_to_uint <- port4me:::string_to_uint

message("* string_to_uint() ...")

hash <- string_to_uint("")
print(hash)
stopifnot(hash == 0)

hash <- string_to_uint("A")
print(hash)
stopifnot(hash == 65)

hash <- string_to_uint("alice,rstudio")
print(hash)
stopifnot(hash == 3688618396)

hash <- string_to_uint("port4me - get the same, personal, free TCP port over and over")
stopifnot(hash == 1731535982)

message("* string_to_uint() ... done")
