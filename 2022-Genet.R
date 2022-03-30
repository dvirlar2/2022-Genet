# Daphne Virlar-Knight
# March 21 2022


# Ticket 24215: https://support.nceas.ucsb.edu/rt/Ticket/Display.html?id=24215&results=49d93d1872555a9122898c3f9884a614
# Dataset: https://arcticdata.io/catalog/view/urn%3Auuid%3Abd75abb0-8b81-42c8-876f-90bf7b47913a


## -- load libraries -- ##
library(dataone)
library(datapack)
library(uuid)
library(arcticdatautils)
library(EML)


## -- general setup -- ##
# run token in console


# get nodes
d1c <- dataone::D1Client("PROD", "urn:node:ARCTIC")


# Get the package
packageId <- "resource_map_urn:uuid:65fe8953-47d7-4d22-895e-fdce2f810013"
dp <- getDataPackage(d1c, identifier = packageId, lazyLoad=TRUE, quiet=FALSE)


# Get the metadata id
xml <- selectMember(dp, "sysmeta@fileName", ".xml")


# Read in the metadata
doc <- read_eml(getObject(d1c@mn, xml))




## -- Find Reference Files -- ##
# Reference files are those that contain TFS_*_ncar.nc
# These have attribute tables that need to be copied over to other datasets

# Find RH files
which_in_eml(doc$dataset$otherEntity, "entityName", 
             function(x) {
               grepl("TFS_..._yearly_ncar.nc", x) # looking for the reference files
             })
# [1] 4 7 10  
# [1] 1 

doc$dataset$otherEntity[[10]]$entityName
# [1] == TFS_RH_yearly_ncar.nc
# [4] == TFS_NPP_yearly_ncar.nc
# [7] == TFS_GPP_yearly_ncar.nc
# [10] == TFS_ALD_yearly_ncar.nc




## -- Apply RH Reference to Other Files -- ##
# What are the indices for the RH files?
which_in_eml(doc$dataset$otherEntity, "entityName", 
             function(x) {
               grepl("_RH_", x) # look for names that begin with Q_ (we know this to be discharge files)
             })
# [1] 1 2 3 13 14 15
# Reference is 1

# Assign discharge reference attributes
RH_attList <- doc$dataset$otherEntity[[1]]$attributeList


# Create reference id
doc$dataset$otherEntity[[1]]$attributeList$id <- "RH_attributes" # use any unique name for your id

for (i in c(2, 3, 13:15)){
  doc$dataset$otherEntity[[i]]$attributeList <- RH_attList
  doc$dataset$otherEntity[[i]]$attributeList <- list(references = "RH_attributes") # use the id you set above
}

eml_validate(doc)
# TRUE



## -- Apply NPP Reference to Other Files -- ##
# What are the indices for the NPP files?
which_in_eml(doc$dataset$otherEntity, "entityName", 
             function(x) {
               grepl("_NPP_", x)
             })
# [1] 4 5 6 16 17 18
# Reference is 4

# Assign discharge reference attributes
NPP_attList <- doc$dataset$otherEntity[[4]]$attributeList


# Create reference id
doc$dataset$otherEntity[[4]]$attributeList$id <- "NPP_attributes" # use any unique name for your id

for (i in c(5, 6, 16:18)){
  doc$dataset$otherEntity[[i]]$attributeList <- NPP_attList
  doc$dataset$otherEntity[[i]]$attributeList <- list(references = "NPP_attributes") # use the id you set above
}

eml_validate(doc)
# TRUE



## -- Apply GPP Reference to Other Files -- ##
# What are the indices for the NPP files?
which_in_eml(doc$dataset$otherEntity, "entityName", 
             function(x) {
               grepl("_GPP_", x)
             })
# [1] 7  8  9 19 20 21
# Reference is 7

# Assign discharge reference attributes
GPP_attList <- doc$dataset$otherEntity[[7]]$attributeList


# Create reference id
doc$dataset$otherEntity[[7]]$attributeList$id <- "GPP_attributes" # use any unique name for your id

for (i in c(8, 9, 19:21)){
  doc$dataset$otherEntity[[i]]$attributeList <- GPP_attList
  doc$dataset$otherEntity[[i]]$attributeList <- list(references = "GPP_attributes") # use the id you set above
}

eml_validate(doc)
# TRUE




## -- Apply ALD Reference to Other Files -- ##
# What are the indices for the NPP files?
which_in_eml(doc$dataset$otherEntity, "entityName", 
             function(x) {
               grepl("_ALD_", x)
             })
# [1] 10 11 12 22 23 24
# Reference is 10

# Assign discharge reference attributes
ALD_attList <- doc$dataset$otherEntity[[10]]$attributeList


# Create reference id
doc$dataset$otherEntity[[10]]$attributeList$id <- "ALD_attributes" # use any unique name for your id

for (i in c(11, 12, 22:24)){
  doc$dataset$otherEntity[[i]]$attributeList <- ALD_attList
  doc$dataset$otherEntity[[i]]$attributeList <- list(references = "ALD_attributes") # use the id you set above
}

eml_validate(doc)
# TRUE

## -- NOTES -- ##
# At this point, I still have the Final.zip folder in the landing page.
# I want to get rid of this, but only after I update the package.
# Once I update, I'll:
  # Remove zip folder from package through webform
  # Change otherEntities to dataTables
  # Change descriptions 
  # Add physicals
  # Add FAIR practices


## -- Update package -- ##
eml_path <- "~/Scratch/Dynamic_Vegetation_Model_Dynamic_Organic_Soil.xml"
write_eml(doc, eml_path)

dp <- replaceMember(dp, xml, replacement = eml_path)

myAccessRules <- data.frame(subject="CN=arctic-data-admins,DC=dataone,DC=org", 
                            permission="changePermission")
packageId <- uploadDataPackage(d1c, dp, public = FALSE,
                               accessRules = myAccessRules, quiet = FALSE)


## -- NOTES -- ##
# Descriptions from entities didn't carry over, adding them now.




## -- Apply RH Description to Relevant Files -- ##
# [1] 1 2 3 13 14 15
# Reference is 1

# Assign discharge reference attributes
RH_description <- doc$dataset$otherEntity[[1]]$entityDescription


for (i in c(2, 3, 13:15)){
  doc$dataset$otherEntity[[i]]$entityDescription <- RH_description
}

eml_validate(doc)
# TRUE



## -- Apply NPP Description to Relevant Files -- ##
# [1] 4 5 6 16 17 18
# Reference is 4

# Assign discharge reference attributes
NPP_description <- doc$dataset$otherEntity[[4]]$entityDescription


for (i in c(5, 6, 16:18)){
  doc$dataset$otherEntity[[i]]$entityDescription <- NPP_description
}

eml_validate(doc)
# TRUE



## -- Apply GPP Reference to Other Files -- ##
# [1] 7  8  9 19 20 21
# Reference is 7

# Assign discharge reference attributes
GPP_description <- doc$dataset$otherEntity[[7]]$entityDescription


for (i in c(8, 9, 19:21)){
  doc$dataset$otherEntity[[i]]$entityDescription <- GPP_description
}

eml_validate(doc)
# TRUE




## -- Apply ALD Reference to Other Files -- ##
# [1] 10 11 12 22 23 24
# Reference is 10

# Assign discharge reference attributes
ALD_description <- doc$dataset$otherEntity[[10]]$entityDescription


for (i in c(11, 12, 22:24)){
  doc$dataset$otherEntity[[11]]$entityDescription <- ALD_description
}

eml_validate(doc)
# TRUE



## -- Update package -- ##
eml_path <- "~/Scratch/Dynamic_Vegetation_Model_Dynamic_Organic_Soil.xml"
write_eml(doc, eml_path)

dp <- replaceMember(dp, xml, replacement = eml_path)

myAccessRules <- data.frame(subject="CN=arctic-data-admins,DC=dataone,DC=org", 
                            permission="changePermission")
packageId <- uploadDataPackage(d1c, dp, public = FALSE,
                               accessRules = myAccessRules, quiet = FALSE)



## -- Fix NSF Awards Section -- ##
awards <- c("1504091")
proj <- eml_nsf_to_project(awards, eml_version = "2.2.0")

doc$dataset$project <- proj
eml_validate(doc)





## -- Change otherEntity to dataTable -- ##
# Change otherEntity to dataTable
doc <- eml_otherEntity_to_dataTable(doc, 1:length(doc$dataset$otherEntity),
                                    validate_eml = F)

eml_validate(doc)


## -- add physicals -- ##
# Get list of all pids and associated file names
all_pids <- get_package(d1c@mn, packageId, file_names = TRUE)
all_pids <- reorder_pids(all_pids$data, doc) #lines up pids w/correct file

# for loop to assign physicals for each file 
for (i in 1:length(all_pids)){
  doc$dataset$dataTable[[i]]$physical <- pid_to_eml_physical(d1c@mn, all_pids[[i]])
}

eml_validate(doc)



## -- add FAIR data practices -- ##
doc <- eml_add_publisher(doc)
doc <- eml_add_entity_system(doc)



## -- Update package -- ##
eml_path <- "~/Scratch/Dynamic_Vegetation_Model_Dynamic_Organic_Soil.xml"
write_eml(doc, eml_path)

dp <- replaceMember(dp, xml, replacement = eml_path)

myAccessRules <- data.frame(subject="CN=arctic-data-admins,DC=dataone,DC=org", 
                            permission="changePermission")
packageId <- uploadDataPackage(d1c, dp, public = FALSE,
                               accessRules = myAccessRules, quiet = FALSE)


## -- add discipline categorization -- ## 
doc <- eml_categorize_dataset(doc, c("Soil Science", "Ecology"))

# don't want to copy/paste again; run update package section above



## -- Publish With DOI -- ##
# generate doi
doi <- dataone::generateIdentifier(d1c@mn, "DOI")

eml_path <- "~/Scratch/Dynamic_Vegetation_Model_Dynamic_Organic_Soil.xml"
write_eml(doc, eml_path)


# publish doi
dp <- replaceMember(dp, xml, replacement=eml_path, newId=doi)

myAccessRules <- data.frame(subject="CN=arctic-data-admins,DC=dataone,DC=org", 
                            permission="changePermission")

newPackageId <- uploadDataPackage(d1c, dp, public=TRUE, quiet=FALSE)
