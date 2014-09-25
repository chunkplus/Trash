#######################################################################
#	> File Name: Makefile
#	> Author: chunk
#	> Mail: chunkplus@gmail.com 
#######################################################################

EXEC =basic

#FLAGS
CC = mpicc
CFLAGS = -g -Wall -ansi

#LIBS
LDDIR = -L/usr/local/lib
LIBS = 	

#INCLUDE
IDIR =	
_DEPS =
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))
INCDIR = $(IDIR)

#OBJECTS
OBJDIR= ./obj
SRCDIR= .
SRCS = $(foreach dir,$(subst :, ,$(SRCDIR)),$(wildcard $(dir)/*.c))
OBJ_PATH = $(addprefix $(OBJDIR)/,$(subst :, ,$(SRCDIR)))
OBJS = $(addprefix $(OBJDIR)/,$(subst .cpp,.o,$(SRCS)))

#START
.PHONY:all clean

all:$(EXEC)

$(EXEC):$(OBJS)
	$(CC) $(CFLAGS) -o $@  $^  $(INCDIR) $(LDDIR) $(LIBS)
	
$(OBJDIR)/%.o:%.cpp
	mkdir -p $(OBJ_PATH)
	$(CC) $(CFLAGS) -c -o $@  $< $(INCDIR)		

clean:
	rm -f -r $(EXEC) $(OBJDIR)
run:$(EXEC)
	mpirun -np 2 $(EXEC)
