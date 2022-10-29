port <- port4me()
print(port)

port <- port4me(tool = "rstudio")
print(port)

port <- port4me("rstudio") ## short for the above
print(port)

ports <- port4me(tool = "rstudio", list = 5L)
print(ports)

avail <- port4me(test = 4321)
print(avail)


