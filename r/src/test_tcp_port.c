#include <Rdefines.h>

#include <unistd.h>

#ifdef _WIN32
#include <winsock2.h>
#else
#include <netinet/in.h>
#endif

// Adopted from https://github.com/ropensci/ssh/blob/master/src/tunnel.c
// which is released under the MIT license
static int test_tcp_port(int port, int test) {
  // Define server socket
  struct sockaddr_in serv_addr;
  memset(&serv_addr, '0', sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  serv_addr.sin_port = htons(port);

  // Create the listening socket
  int listenfd = socket(AF_INET, SOCK_STREAM, 0);
  if (listenfd < 0) {
    return 0;
  }

  // Allow immediate reuse of a port in TIME_WAIT state.
  // for Windows see TcpTimedWaitDelay (doesn't work)
#ifndef _WIN32
  int enable = 1;
  if (setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int)) < 0) {
    return 0;
  }
#endif

  // Test if we can bind to the port?
  if (test & 1) {
    if (bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0) {
      return 0;
    }
  }

  // Test if we can listen to the port?
  if (test & 2) {
    if (listen(listenfd, 0) < 0) {
      return 0;
    }
  }


#ifdef _WIN32
  closesocket(listenfd);
#else
  close(listenfd);
#endif
  
  return 1;
}


SEXP R_test_tcp_port(SEXP port_, SEXP test_) {
  int port = 0;
  int test = 0;

  /* Argument 'port': */
  if (!isInteger(port_)) {
    error("Argument 'port' must be an integer");
  } else if (xlength(port_) != 1) {
    error("Argument 'port' must be an single integer");
  }
  port = (int)asInteger(port_);

  /* Argument 'test': */
  if (!isInteger(test_)) {
    error("Argument 'test' must be an integer");
  } else if (xlength(test_) != 1) {
    error("Argument 'test' must be an single integer");
  }
  test = (int)asInteger(test_);

  if (test_tcp_port(port, test)) {
    return(ScalarLogical(TRUE));
  } else {
    return(ScalarLogical(FALSE));
  }
}  
