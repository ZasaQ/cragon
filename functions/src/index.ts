import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const createDragonDocumentOnDirectoryAddition = functions
  .storage.object().onFinalize(async (object) => {
    if (!object.name) {
      console.log("object.name is null");
      return;
    }
    console.log("Log: object.contentType:", object.contentType);
    console.log("Log: object.name:", object.name);
    if (object.contentType !=
      "application/x-www-form-urlencoded;charset=UTF-8") {
      return;
    }
    if (!object.name.startsWith("dragonsGalleries/")) {
      return;
    }
    const directoryName = object.name.split("/")[1];
    console.log("Firestore document creation start:", directoryName);
    try {
      await admin.firestore().collection("dragons").doc(directoryName).set({
        "directoryName": directoryName,
        "displayName": "",
        "createdAt": admin.firestore.FieldValue.serverTimestamp(),
        "dragonLocation": new admin.firestore.GeoPoint(0, 0),
      });
      console.log("Firestore document created for dragon:", directoryName);
    } catch (error) {
      console.error("Error creating Firestore document:", error);
    }
  });

export const deleteDragonDocumentOnDirectoryRemoval = functions
  .storage.object().onDelete(async (object) => {
    if (!object.name) {
      console.log("object.name is null");
      return;
    }
    console.log("Log: object.contentType:", object.contentType);
    console.log("Log: object.name:", object.name);
    if (object.contentType !=
      "application/x-www-form-urlencoded;charset=UTF-8") {
      return;
    }
    if (!object.name.startsWith("dragonsGalleries/")) {
      return;
    }
    const directoryName = object.name.split("/")[1];
    console.log("Firestore document removal start:", directoryName);
    try {
      await admin.firestore().collection("dragons")
        .doc(directoryName).delete({});
      console.log("Firestore dragon document removed:", directoryName);
    } catch (error) {
      console.error("Error deleting Firestore document:", error);
    }
  });
