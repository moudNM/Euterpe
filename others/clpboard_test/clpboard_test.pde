import java.awt.*;
import java.awt.datatransfer.*;
import java.io.*;

Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();

try {
  println(clipboard.getData(DataFlavor.stringFlavor));
}
catch(Exception e) {
}