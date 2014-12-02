#!/bin/bash
##################
# Creates a project for the most recent simulator instance.
#
# Usage:
#     createCoreDataProject.sh [MODEL_NAME] [PERSISTENT_STORE] [PROJECT_FILE_NAME]
#
# MODEL_NAME - The file name of the applications model file. (NSManagedObjectModel)
#
# PERSISTENT_STORE - This is the name of persistent store. (NSPersistentStoreCoordinator)
#
# PROJECT_FILE_NAME - The name that the project file will be staved to.
#
##################

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "-------------------"
    echo "Usage:"
    echo ""
	echo "createCoreDataProject.sh [MODEL_NAME] [PERSISTENT_STORE] [PROJECT_FILE_NAME]"
	echo ""
	echo "MODEL_NAME - The file name of the applications model file. (NSManagedObjectModel)"
	echo ""
	echo "PERSISTENT_STORE - This is the name of persistent store. (NSPersistentStoreCoordinator)"
	echo ""
	echo "PROJECT_FILE_NAME - The name that the project file will be staved to."
	echo "-------------------"
    exit -1
fi


BIN_DIR=`dirname "$0"`
SIM_DIR=~/Library/Developer/CoreSimulator/Devices
DEST_DIR=/tmp

PROJECT_NAME=$3
MODEL_NAME=$1
DATA_NAME=$2

# get last modified simulator folder (should be active/last running simulator)
LAST_MODIFIED=`ls -t $SIM_DIR | head -1`

CONTAINER_DIR=$SIM_DIR/$LAST_MODIFIED/data/Containers
cd $CONTAINER_DIR

# find model
MODEL_PATH=`find . -name $MODEL_NAME`

# find data file
DATA_PATH=`find . -name $DATA_NAME`

# create project file
rm $DEST_DIR/$PROJECT_NAME
/usr/libexec/PlistBuddy -c "Add :modelFilePath string \"file://$CONTAINER_DIR/$MODEL_PATH\"" $DEST_DIR/$PROJECT_NAME
/usr/libexec/PlistBuddy -c "Add :storeFilePath string \"file://$CONTAINER_DIR/$DATA_PATH\"" $DEST_DIR/$PROJECT_NAME
/usr/libexec/PlistBuddy -c "Add :storeFormat integer 1" $DEST_DIR/$PROJECT_NAME
/usr/libexec/PlistBuddy -c "Add :v integer 1" $DEST_DIR/$PROJECT_NAME

echo "project created: $DEST_DIR/$PROJECT_NAME"

open $DEST_DIR/$PROJECT_NAME
# read -p "open project? (y/n) " yn
# case $yn in
#     [Yy]* ) open $DEST_DIR/$PROJECT_NAME; break;;
#     * ) exit ;;
# esac
