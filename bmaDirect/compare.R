## We pull together the info from dataBase.R and analyze.R
## The key data structure from each are nndata (from analyze.R) and
## mobleyTruthData (from dataBase.R)

## Merge the truth data into nndata
nndata.merge <- cbind(nndata, expmtVal=NA, expmtUnc=NA, mobleyVal=NA, mobleyUnc=NA)
dim(nndata)
dim(nndata.merge)
dimnames(nndata.merge)

use.cols <- c("expmtVal", "expmtUnc", "mobleyVal", "mobleyUnc")

nndata.sampleType <- rep("unknn", nrow(nndata.merge))
names(nndata.sampleType) <- rownames(nndata.merge)

for( the.key in rownames(nndata.merge)) {
    mobley.indi <- mobleyTruthData$sampleKey == the.key
    if( sum(mobley.indi) == 1 ) {
        nndata.merge[the.key,use.cols] <- as.numeric(mobleyTruthData[mobley.indi, use.cols])
        nndata.sampleType[the.key] <- mobleyTruthData$sampleType[mobley.indi]
    }
}

nndata.merge[,"expmtVal"]
nndata.sampleType


## More plots
pdf("pairwise.pdf", paper="letter")
for(theDataName in simplerNames) {
    the.cor <- cor(nndata.merge[, theDataName],
                   nndata.merge[, "expmtVal"],
                   use="complete")
    combo.ylim <- range(c(nndata.merge[, theDataName], nndata.merge[, "expmtVal"]), na.rm=TRUE)
    plot(nndata.merge[, theDataName], nndata.merge[, "expmtVal"],
         main=paste(theDataName, format(the.cor, digits=3)), ylim=combo.ylim, xlim=combo.ylim,
         xlab="Model based estimate of solvation free energy (kcal/mol)",
         ylab="Experiment based estimate of solvation free energy (kcal/mol)", type="n")
    typeBlind.indi <- nndata.sampleType == "blind"
    typeSuppl.indi <- nndata.sampleType == "suppl"
    typeUnknn.indi <- nndata.sampleType == "unknn"
    if( any(typeBlind.indi) )
        points(nndata.merge[typeBlind.indi, theDataName], nndata.merge[typeBlind.indi, "expmtVal"], pch=1)
    if( any(typeSuppl.indi) )
        points(nndata.merge[typeSuppl.indi, theDataName], nndata.merge[typeSuppl.indi, "expmtVal"], pch=2)
    if( any(typeUnknn.indi) )
        points(nndata.merge[typeUnknn.indi, theDataName], nndata.merge[typeUnknn.indi, "expmtVal"], pch=4)

    abline(a=0, b=1, col="blue")
}

## OK - here's the cheese
average.est <- apply(nndata.merge[,simplerNames], 1, mean, na.rm=TRUE)
the.cor <- cor(average.est, nndata.merge[,"expmtVal"], use="complete")
combo.ylim <- range(c(average.est, nndata.merge[, "expmtVal"]), na.rm=TRUE)
plot(average.est, nndata.merge[, "expmtVal"], main=paste("average",
                                              format(the.cor,
                                                     digits=3)),
     xlim=combo.ylim, ylim=combo.ylim,
     xlab="Average estimate of solvation free energy",
     ylab="Experiment based estimate of solvation free energy (kcal/mol)")
abline(a=0, b=1, col="blue")
##dev.off()

## More cheese - of the BMA form

## let's take a look at the model uncertainties
## They aren't universally available, nor are they all in the same units
nndata[,91:135]
## quickest fix - the model uncertainty of zero is as good as an NA. We can't use it.
## Issue - need a way to compare model uncertainties on a quant scale vs a qual scale

## Initially: take the numbers at face value (except for zero - that's an NA)
model.means <- nndata[,simplerNames]
model.sd <- nndata[,paste(simplerNames,rep("msd",nncols), sep=".")]
model.sd[,"145.lhs@sampl4.msd"] <- NA

## And it's not obvious how to go from 'model standard deviation' to pr(M|D)
## Simplest idea for the moment: they are proportional

dim(model.means)
dim(model.sd)

model.normalize <-
    rowSums(model.sd, na.rm=TRUE)
sum(model.sd[1,] / model.normalize[1], na.rm=T)

model.unc <-
    model.sd / model.normalize

dim(model.unc)

sum( model.unc[1,], na.rm=TRUE)
sum( model.unc[2,], na.rm=TRUE)

bma.cheese1 <-
    rowSums(model.means * model.unc, na.rm=TRUE)

the.cor <- cor(bma.cheese1, nndata.merge[,"expmtVal"], use="complete")
combo.ylim <- range( c(bma.cheese1, nndata.merge[,"expmtVal"]), na.rm=TRUE)
plot(bma.cheese1, nndata.merge[, "expmtVal"], main=paste("bma v1",
                                              format(the.cor,
                                                     digits=3)),
     xlab="BMA v1", ylab="Experiment based estimate of solvation free energy (kcal/mol)",
     xlim=combo.ylim, ylim=combo.ylim)
abline(a=0, b=1, col="blue")
dev.off()
