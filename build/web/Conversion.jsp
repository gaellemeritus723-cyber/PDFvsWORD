<%-- 
    Document   : Conversion
    Created on : Jan 20, 2026, 4:15:35 PM
    Author     : User
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        
        <div class="result-card">
    <div class="success-icon">✅</div>
    <h1>Conversion terminée !</h1>
    <p>Votre fichier <strong>${FileName}</strong> est prêt.</p>
    
    <a href="${downloadLink}" class="btn-download">
        📥 Télécharger le fichier
    </a>
    
    <hr>
    <a href="designPro.jsp">Convertir un autre fichier</a>
</div>
        
       
       
    </body>
</html>


<script>
function updateFileName() {
    const input = document.getElementById('fileInput');
    const container = document.getElementById('previewContainer');
    const headerTitle = document.getElementById('preview-filename');
    
    if (input.files.length > 0) {
        const file = input.files[0];
        const fileURL = URL.createObjectURL(file);
        headerTitle.innerText = "Aperçu : " + file.name;

        // Si c'est un PDF
        if (file.type === "application/pdf") {
            container.innerHTML = `<iframe src="${fileURL}" width="100%" height="100%" style="border:none; border-radius:12px;"></iframe>`;
        } 
        // Si c'est une image (optionnel)
        else if (file.type.startsWith("image/")) {
            container.innerHTML = `<img src="${fileURL}" style="max-width:90%; max-height:90%; border-radius:8px; box-shadow: 0 4px 12px rgba(0,0,0,0.2);">`;
        }
        // Si c'est un Word (.docx)
        else {
            container.innerHTML = `
                <div class="empty-state">
                    <div style="font-size: 4rem;">📝</div>
                    <h3>Document Word détecté</h3>
                    <p>Le format <strong>${file.name}</strong> ne peut pas être prévisualisé directement, mais il est prêt à être converti en PDF.</p>
                </div>`;
        }
    }
    }

</script>