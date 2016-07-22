## Where's the data
dataDirectory <- "SI_files/submission_shares"

## The data -- the second of the two provides the basic data
dir(dataDirectory)
dir(dataDirectory, pattern="*.data$")

theDataFileNames <- dir(dataDirectory, pattern="*.data$")

## pattern for the data
data.what <- list(sample="", freeEnergy=0, statErr=0, modelErr=0)

## I read one
assign(theDataFileNames[1],
       scan(file=paste(dataDirectory, theDataFileNames[1], sep="/"), what=data.what, sep=","))

get(theDataFileNames[1])

## Need more care in reading the data files to fileter out the comment lines
## Approach:
##  read the file line,
##  do a grep to filter out those with a leading '#',
##  write the remaining lines into a remporary file,
##  read the temporary file
read.data.file <- function(fileName, use.path=dataDirectory) {
    fileLines <- scan(paste(use.path, fileName, sep="/"), sep="\n", what="")
    comment.lines <- grep("^#", fileLines)

    the.file <- paste(use.path, fileName, sep="/")
    if( length(comment.lines) != 0 ) { ## use the current file name
        the.file <- tempfile()
        cat(fileLines[-comment.lines],sep="\n", file=the.file)
    }

    scan(file=the.file, what=data.what, sep=",", multi.line=F, flush=TRUE)
}

## testing...
read.data.file(theDataFileNames[1])
read.data.file(theDataFileNames[3])
read.data.file(theDataFileNames[44])

## Read them all
for(theDataName in theDataFileNames) {
    cat(theDataName,"\n")
    assign(theDataName,
           read.data.file(theDataName))
}

require('gplots')
plot.entry <- function(xx, use.sd=2, main="") {
    nn <- length(xx$sample)
    yrange <- range( c(xx$freeEnergy+use.sd*xx$statErr,
                       xx$freeEnergy-use.sd*xx$statErr) )
    plotCI(xx$freeEnergy, uiw=use.sd*xx$statErr, main=main)
}

plot.entry(get(theDataFileNames[1]), main=theDataFileNames[1])

pdf(file="firstLook.pdf", paper="letter")
for(theDataName in theDataFileNames) {
    plot.entry(get(theDataName), main=theDataName)
}
dev.off()

## Write a big data desk readable file
data1 <- read.data.file(theDataFileNames[1])
nnrows <- length(data1[[1]])
nncols <- length(theDataFileNames)
nndata <- matrix(nrow=nnrows, ncol=nncols*3)
simplerNames <-
    sub(".data","", theDataFileNames)
dimnames(nndata) <- list(data1$sample,
                         c(simplerNames, paste(simplerNames,rep("dsd",nncols), sep="."),
                           paste(simplerNames,rep("msd",nncols), sep=".")))
for(theDataName in simplerNames) {
    cat(theDataName,"\n")

    the.data <- get(paste(theDataName,"data",sep="."))

    ## check the compound names for consistency
    indi <- data1$sample %in% the.data$sample
    if( !all(indi) ) {
        cat("  slight mismatch in samples\n")
    }

    ## read/write the estimates
    nndata[indi,theDataName] <- the.data$freeEnergy

    ## read/write the statistical errs
    nndata[indi,paste(theDataName,"dsd",sep=".")] <- the.data$statErr

    ## read/write the model errs
    nndata[indi,paste(theDataName,"msd",sep=".")] <- the.data$modelErr
}
write.table(nndata, file="freeEnergy.csv", sep=",", row.names=T, col.names=T)

#### Test code
####
## data(state)
## tmp <- split(state.area, state.region)
## means <- sapply(tmp, mean)
## stdev <- sqrt(sapply(tmp, var))
## n <- sapply(tmp,length)
## ciw <- qt(0.975, n) * stdev / sqrt(n)
## # plain
## plotCI(x=means, uiw=ciw)
## # prettier
## plotCI(x=means, uiw=ciw, col="black", barcol="blue", lwd=1)
## # give mean values
## plotCI(x=means, uiw=ciw, col="black", barcol="blue",
## labels=round(means,-3), xaxt="n", xlim=c(0,5) )
## axis(side=1, at=1:4, labels=names(tmp), cex=0.7)
## # better yet, just use plotmeans ... #
## plotmeans( state.area ~ state.region )
