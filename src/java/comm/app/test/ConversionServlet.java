package comm.app.test;

import com.convertapi.client.Config;
import com.convertapi.client.ConvertApi;
import com.convertapi.client.Param;
import java.io.*;
import java.nio.file.Paths;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/ConversionServlet")
@MultipartConfig
public class ConversionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Configuration du jeton
        Config.setDefaultApiCredentials("gpNGWAUW0rQytL0OBp4c7VcDYHtUEDEX");

        // 2. Récupération du fichier envoyé
        Part filePart = request.getPart("fileInput");
        String fileName = filePart.getSubmittedFileName();
        String formatCible = request.getParameter("formatCible");
        String formatSource = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();

        File tempFile = new File(System.getProperty("java.io.tmpdir") + "/" + fileName);
        filePart.write(tempFile.getAbsolutePath());

        try {

            String outputDir = System.getProperty("java.io.tmpdir");

            // 3. Conversion correcte
            var result = ConvertApi.convert(formatSource, formatCible,
                    new Param("File", Paths.get(tempFile.getAbsolutePath()))
            ).get();

            var savedFiles = result.saveFilesSync(Paths.get(outputDir));

            // ⚠️ On récupère le vrai fichier généré (et non un nom reconstruit)
            File resultFile = savedFiles.get(0).toFile();

            // 4. Envoi du fichier au navigateur
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition",
                    "attachment; filename=\"" + resultFile.getName() + "\"");

            try (FileInputStream fis = new FileInputStream(resultFile);
                 OutputStream os = response.getOutputStream()) {

                fis.transferTo(os);
                os.flush();
            }

        } catch (Exception e) {
            response.getWriter().println("Erreur : " + e.getMessage());
        }
    }
}