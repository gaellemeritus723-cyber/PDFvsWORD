package comm.app.test;

import com.convertapi.client.Config;
import com.convertapi.client.ConvertApi;
import com.convertapi.client.Param;
import java.nio.file.Paths;

import okhttp3.*;
import java.io.File;
import java.io.IOException;

public class TestConversion {

    public void convertir(String cheminFichierSource) {
        OkHttpClient client = new OkHttpClient();
        String monJeton = "gpNGWAUW0rQytL0OBp4c7VcDYHtUEDEX"; // Collez votre jeton ici

        // Préparation du fichier
        File file = new File(cheminFichierSource);

        RequestBody requestBody = new MultipartBody.Builder()
            .setType(MultipartBody.FORM)
            .addFormDataPart("File", file.getName(),
                RequestBody.create(file, MediaType.parse("application/octet-stream")))
            .build();

        // On appelle directement l'URL de conversion Word vers PDF
        Request request = new Request.Builder()
            .url("https://v2.convertapi.com/convert/docx/to/pdf?Secret=" + monJeton)
            .post(requestBody)
            .build();

        try (Response response = client.newCall(request).execute()) {
            if (response.isSuccessful()) {
                System.out.println("Conversion réussie !");
                // Ici vous pourrez sauvegarder le résultat
            } else {
                System.out.println("Erreur : " + response.code() + " " + response.body().string());
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}