#!R --vanilla
require(jsonlite)

work.dir <- Sys.getenv("WORKDIR")
setwd(work.dir)

args <- commandArgs(TRUE)
if (length(args)==2) {
   upload.dir <- args[1]
   inputfile <- read.csv(args[2],sep="|",header=F)
} else {
   print("something is missing")
   q()
}

for (j in 1:nrow(inputfile)) {
   EFG <- inputfile[j,1]
   map_code <-  inputfile[j,2]
   map_version <-  inputfile[j,3]

   # mbtiles are smaller but are probably not included in the free tier
   #upload.arch <- sprintf("%s_%s.mbtiles",map_code,map_version)
   upload.arch <- sprintf("%s_%s_color.tif",map_code,map_version)
   tile.name <- gsub("\\.","_",map_code)
   if (!file.exists(sprintf("%s/%s",upload.dir,upload.arch))) {
      print("No path to the map!")
   } else {
      #print(sprintf("%s %s : %s - %s",upload.dir,EFG,upload.arch,tile.name))
      MB.token <- readLines("~/.mapbox.upload.token")
      MB.user <- "jrfep"
      rslt <- system(sprintf("curl -X POST https://api.mapbox.com/uploads/v1/%s/credentials?access_token=%s",MB.user,MB.token),intern=T)
      dts <-  parse_json(rslt)

      Sys.setenv( AWS_ACCESS_KEY_ID=dts$accessKeyId,
         AWS_SECRET_ACCESS_KEY=dts$secretAccessKey,
         AWS_SESSION_TOKEN=dts$sessionToken)

      system(sprintf("aws s3 cp %s/%s s3://%s/%s --region us-east-1",upload.dir,upload.arch,dts$bucket,dts$key))

      rslt <- system(sprintf("curl -X POST -H \"Content-Type: application/json\" -H \"Cache-Control: no-cache\" -d '{
         \"url\": \"%1$s\",
         \"tileset\": \"%2$s.%3$s\",
         \"name\": \"Indicative map %5$s updated to %6$s %7$s\"
      }' https://api.mapbox.com/uploads/v1/%2$s?access_token=%4$s
      ", dts$url, MB.user, tile.name, MB.token, EFG, map_code, map_version),intern=T)

      final <- parse_json(rslt)

      print(final)
   }
}
