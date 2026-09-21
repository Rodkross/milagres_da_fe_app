class Helpers {
  static String resolveTitle(String title, String gender) {
    if (gender == 'Feminino') {
      switch (title) {
        case 'Obreiro': return 'Obreira';
        case 'Diácono': return 'Diaconisa';
        case 'Presbítero': return 'Presbítera';
        case 'Pastor': return 'Pastora';
        case 'Obreiro(a)': return 'Obreira';
        case 'Diácono / Diaconisa': return 'Diaconisa';
        case 'Presbítero(a)': return 'Presbítera';
        case 'Pastor(a)': return 'Pastora';
      }
    } else { // Masculino or fallback
      switch (title) {
        case 'Obreiro(a)': return 'Obreiro';
        case 'Diácono / Diaconisa': return 'Diácono';
        case 'Presbítero(a)': return 'Presbítero';
        case 'Pastor(a)': return 'Pastor';
      }
    }
    return title; 
  }
}
