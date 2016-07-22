## Work with the database of hydration free energy's and merge with
## the test molecules.

mobley.what <- list(key="", SMILES="", iupacName="", expmtVal=0,
                    expmtUnc=0, mobleyVal=0, mobleyUnc=0, expmtRef="", calcRef="",
                    PubChemID="", notes="")

mobleyLines <- scan("v0.31/database.txt", skip=3, what="", sep="\n")
ndata <- length(mobleyLines)
split.lines <- strsplit(mobleyLines, "; ")

mobleyDB <- mobley.what

for(i in seq(ndata)) {
    for(j in seq(11)) {
        mobleyDB[[j]][i] <- split.lines[[i]][j]
    }
}
names(mobleyDB)
mobleyDB$expmtVal <- as.numeric(mobleyDB$expmtVal)
mobleyDB$expmtUnc <- as.numeric(mobleyDB$expmtUnc)
mobleyDB$mobleyVal <- as.numeric(mobleyDB$mobleyVal)
mobleyDB$mobleyUnc <- as.numeric(mobleyDB$mobleyUnc)

mobleyDB.frame <- data.frame(mobleyDB)
## This failed. Dunno why. Line 501 of the data
## mobleyDB <- scan("v0.31/database.txt", skip=3, sep=";",
##                  what=mobley.what, flush=TRUE, multi.line=FALSE)

#### Now we link the experimental values with the database keys from
#### the papers
grp1 <- scan("SI_files/inputs/blind/title_vs_smiles.txt",
             what=list(samplKey="", SMILES=""), flush=TRUE,
             multi.line=FALSE)
grp2 <- scan("SI_files/inputs/supplementary/title_vs_smiles.txt",
             what=list(samplKey="", SMILES=""), flush=TRUE,
             multi.line=FALSE)

## Can we look up the grp1, grp2 in the database?
grp1$SMILES[!(grp1$SMILES %in% mobleyDB$SMILES)]

grp2$SMILES[!(grp2$SMILES %in% mobleyDB$SMILES)]

## let's build a database of truth vals
indi1 <- mobleyDB$SMILES %in% grp1$SMILES
indi2 <- mobleyDB$SMILES %in% grp2$SMILES
sum(indi1)
sum(indi2)
sum(indi1|indi2)

mobleyTruthData <-
    mobleyDB.frame[indi1|indi2,]

ncol(mobleyTruthData)
nrow(mobleyTruthData)

smiles <- rep("", nrow(mobleyTruthData))

indi1 <-
    mobleyTruthData$SMILES %in% grp1$SMILES
indi2 <-
    mobleyTruthData$SMILES %in% grp1$SMILES

for(i in seq(length(grp1[[1]]))) {
    iii <- as.character(grp1$SMILES)[i]
    indi <- iii == as.character(mobleyTruthData$SMILES)
    if( sum(indi) == 1 ) {
        smiles[indi] <- as.character(grp1$samplKey)[i]
    }
}
for(i in seq(length(grp2[[1]]))) {
    iii <- as.character(grp2$SMILES)[i]
    indi <- iii == as.character(mobleyTruthData$SMILES)
    if( sum(indi) == 1 ) {
        smiles[indi] <- as.character(grp2$samplKey)[i]
    }
}
mobleyTruthData$sampleKey <- smiles


######
###### Blind v supplementary
blindSamples <- scan("blind.txt", what="", sep="\n")
suppSamples <- scan("supplementary.txt", what="", sep="\n")

## link the blind and supplementary info with the mobleyTruthData
blind.indi <- mobleyTruthData$sampleKey %in% blindSamples
suppl.indi <- mobleyTruthData$sampleKey %in% suppSamples

sampleType <- rep("unknn", length(mobleyTruthData$sampleKey))
sampleType[blind.indi] <- "blind"
sampleType[suppl.indi] <- "suppl"
sampleType
table(sampleType)

names(sampleType) <- mobleyTruthData$sampleKey
sampleType

mobleyTruthData$sampleType <- sampleType
mobleyTruthData$sampleType
