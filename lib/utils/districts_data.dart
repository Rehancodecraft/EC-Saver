// Districts and Tehsils data for Punjab, Pakistan
const Map<String, List<String>> districtsData = {
  "Lahore": [
    "Lahore City",
    "Lahore Cantt",
    "Model Town",
    "Shalimar",
    "Raiwind",
    "Allama Iqbal",
    "Nishtar",
    "Saddar",
    "Wahga",
    "Ravi"
  ],
  "Kasur": [
    "Kasur",
    "Kot Radha Kishan",
    "Chunian",
    "Pattoki"
  ],
  "Sheikhupura": [
    "Sheikhupura",
    "Ferozwala",
    "Muridke",
    "Sharaqpur",
    "Safdarabad"
  ],
  "Nankana Sahib": [
    "Nankana Sahib",
    "Shahkot",
    "Sangla Hill"
  ],
  "Gujranwala": [
    "Gujranwala City",
    "Gujranwala Sadar",
    "Kamoke",
    "Naushera Virkan"
  ],
  "Sialkot": [
    "Sialkot",
    "Daska",
    "Pasrur",
    "Sambrial"
  ],
  "Narowal": [
    "Narowal",
    "Shakargarh",
    "Zafarwal"
  ],
  "Gujrat": [
    "Gujrat",
    "Kharian",
    "Sarai Alamgir",
    "Jalalpur Jattan",
    "Khunjah"
  ],
  "Hafizabad": [
    "Hafizabad",
    "Pindi Bhattian"
  ],
  "Mandi Bahauddin": [
    "Mandi Bahauddin",
    "Phalia",
    "Malakwal"
  ],
  "Wazirabad": [
    "Wazirabad",
    "Alipur Chatha"
  ],
  "Rawalpindi": [
    "Rawalpindi Saddar",
    "Rawalpindi Cantt",
    "Rawalpindi City",
    "Kahuta",
    "Taxila",
    "Kallar Syedan",
    "Gujar Khan"
  ],
  "Murree": [
    "Murree",
    "Kotli Sattian"
  ],
  "Chakwal": [
    "Chakwal",
    "Choa Saidan Shah",
    "Kallar Kahar"
  ],
  "Attock": [
    "Attock",
    "Hassan Abdal",
    "Fateh Jang",
    "Jand",
    "Pindi Gheb",
    "Hazro"
  ],
  "Jhelum": [
    "Jhelum",
    "Pind Dadan Khan",
    "Sohawa",
    "Dina"
  ],
  "Talagang": [
    "Talagang",
    "Lawa"
  ],
  "Multan": [
    "Multan City",
    "Multan Saddar",
    "Shujabad",
    "Jalalpur Pirwala"
  ],
  "Lodhran": [
    "Lodhran",
    "Dunyapur",
    "Kahror Pacca"
  ],
  "Vehari": [
    "Vehari",
    "Mailsi",
    "Burewala"
  ],
  "Khanewal": [
    "Khanewal",
    "Mian Channu",
    "Kabirwala",
    "Jahanian"
  ],
  "Sahiwal": [
    "Sahiwal",
    "Chichawatni"
  ],
  "Okara": [
    "Okara",
    "Depalpur",
    "Renala Khurd"
  ],
  "Bahawalpur": [
    "Bahawalpur City",
    "Bahawalpur Saddar",
    "Ahmadpur East",
    "Hasilpur",
    "Khairpur Tamewali",
    "Yazman"
  ],
  "Bahawalnagar": [
    "Bahawalnagar",
    "Chishtian",
    "Fort Abbas",
    "Haroonabad",
    "Minchinabad"
  ],
  "Rahim Yar Khan": [
    "Rahim Yar Khan",
    "Khanpur",
    "Liaquatpur",
    "Sadiqabad"
  ],
  "Dera Ghazi Khan": [
    "Dera Ghazi Khan",
    "De-Excluded Area D.G. Khan",
    "Kot Chutta"
  ],
  "Taunsa": [
    "Taunsa",
    "Koh-e-Suleman",
    "Wahova"
  ],
  "Rajanpur": [
    "Rajanpur",
    "Jampur",
    "Rojhan",
    "De-Excluded Area Rajanpur"
  ],
  "Layyah": [
    "Layyah",
    "Karor Lal Esan",
    "Chaubara"
  ],
  "Kot Addu": [
    "Kot Addu",
    "Chowk Sarwar Shaheed"
  ],
  "Muzaffargarh": [
    "Muzaffargarh",
    "Alipur",
    "Jatoi"
  ],
  "Faisalabad": [
    "Faisalabad City",
    "Faisalabad Saddar",
    "Chak Jhumra",
    "Jaranwala",
    "Samundri",
    "Tandlianwala"
  ],
  "Jhang": [
    "Jhang",
    "Shorkot",
    "Ahmadpur Sial",
    "Athara Hazari"
  ],
  "Chiniot": [
    "Chiniot",
    "Bhawana",
    "Lalian"
  ],
  "Toba Tek Singh": [
    "Toba Tek Singh",
    "Gojra",
    "Kamalia",
    "Pirmahal"
  ],
  "Sargodha": [
    "Sargodha",
    "Bhalwal",
    "Bhera",
    "Kot Momin",
    "Shahpur",
    "Sahiwal (Sargodha Dist)",
    "Sillanwali"
  ],
  "Khushab": [
    "Khushab",
    "Noorpur Thal",
    "Quaidabad"
  ],
  "Mianwali": [
    "Mianwali",
    "Isakhel",
    "Piplan"
  ],
  "Bhakkar": [
    "Bhakkar",
    "Darya Khan",
    "Kaloorkot",
    "Mankera"
  ],
};

List<String> getDistricts() {
  return districtsData.keys.toList()..sort();
}

List<String> getTehsils(String district) {
  return districtsData[district] ?? [];
}
