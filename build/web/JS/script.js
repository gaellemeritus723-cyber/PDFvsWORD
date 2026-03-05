/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/ClientSide/javascript.js to edit this template
 */


function (){
    var form_group = document.querySelection('.form_group');
    var body = document.querySelector('body');
    
    //insertion
    body.innerjsp =`
     <div class="form-group">
                    <label>Choisir votre fichier :</label>
                    <input type="file" name="fileInput" id="fileInput" required onchange="gererApercuAvant()" />
                </div>
`
    
}





























        // Envoi AJAX pour ne pas recharger la page
        document.getElementById('uploadForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            const btn = document.getElementById('btnConvertir');
            const loader = document.getElementById('loaderContainer');
            const bar = document.getElementById('progressBar');

            loader.style.display = 'block';
            btn.disabled = true;

            fetch('ConversionServlet', { method: 'POST', body: formData })
            .then(response => response.blob())
            .then(blob => {
                const url = URL.createObjectURL(blob);
                const format = document.getElementById('formatCible').value;
                
                // 1. Mise à jour de l'aperçu avec le fichier converti
                if (format === "pdf") {
                    document.getElementById('previewBody').innerHTML = `<iframe src="${url}" width="100%" height="100%"></iframe>`;
                } else {
                    document.getElementById('previewBody').innerHTML = `<div class="empty-state">✅ Conversion terminée !</div>`;
                }

                // 2. Configuration des boutons de partage et téléchargement
                document.getElementById('shareSection').style.display = 'flex';
                document.getElementById('dlLink').href = url;
                
                // Note : Pour WhatsApp/Telegram, on partage généralement un lien. 
                // Ici, comme le fichier est local, on propose de partager le texte de succès.
                const shareMsg = encodeURIComponent("J'ai converti mon document avec succès !");
                document.getElementById('waLink').href = `https://wa.me/?text=${shareMsg}`;
                document.getElementById('tgLink').href = `https://t.me/share/url?url=${window.location.href}&text=${shareMsg}`;

                loader.style.display = 'none';
                btn.disabled = false;
                bar.style.width = "100%";
            })
            .catch(err => alert("Erreur : " + err));
        });