const express = require("express");
const fs = require("fs");
const path = require("path");

const router = express.Router();

router.get("/get-file/*", (req, res) => {
  const filePath = path.join("/", req.params[0]);

  const allowedDirectory = "/app";
  if (!filePath.startsWith(allowedDirectory)) {
    return res.status(403).send("Access denied");
  }

  fs.access(filePath, fs.constants.R_OK, (err) => {
    if (err) {
      return res.status(404).send("File not found");
    }

    const mimeType = getMimeType(path.extname(filePath));
    res.setHeader("Content-Type", mimeType);

    const fileStream = fs.createReadStream(filePath);
    fileStream.on("error", (error) => {
      res.status(500).send("Error reading file");
    });

    fileStream.pipe(res);

    res.on("finish", () => {
      fs.unlink(filePath, (err) => {
        if (err) {
          console.error(`Error deleting file: ${filePath}`, err);
        } else {
        }
      });
    });
  });
});

function getMimeType(extension) {
  const mimeTypes = {
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".gif": "image/gif",
  };
  return mimeTypes[extension.toLowerCase()] || "application/octet-stream";
}

module.exports = router;
