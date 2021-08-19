// To parse this JSON data, do
//
//     final suratJalanModel = suratJalanModelFromJson(jsonString);

import 'dart:convert';

SuratJalanModel suratJalanModelFromJson(String str) => SuratJalanModel.fromJson(json.decode(str));

String suratJalanModelToJson(SuratJalanModel data) => json.encode(data.toJson());

class SuratJalanModel {
    SuratJalanModel({
        this.id,
        this.idCustomernya,
        this.namaSupir,
        this.kodeTruck,
        this.idCustomer,
        this.kodeCustomer,
        this.namaCustomer,
        this.buktiOrderTrucking,
        this.tanggalOrderTrucking,
        this.namaPengirim,
        this.kotaPengirim,
        this.alamatPengirim,
        this.namaPenerima,
        this.kotaPenerima,
        this.alamatPenerima,
        this.tanggalAmbil,
        this.jenis,
        this.sektor,
        this.depo,
        this.catatan,
        this.jumlahContainer,
        this.jenisContainer,
        this.antriMuat,
        this.selesaiMuat,
        this.antriBongkar,
        this.selesaiBongkar,
        this.kembaliKeDepo,
        this.tombolberangkat,
        this.berangkat,
    });

    int id;
    int idCustomernya;
    String namaSupir;
    String kodeTruck;
    int idCustomer;
    dynamic kodeCustomer;
    String namaCustomer;
    String buktiOrderTrucking;
    DateTime tanggalOrderTrucking;
    String namaPengirim;
    dynamic kotaPengirim;
    String alamatPengirim;
    String namaPenerima;
    String kotaPenerima;
    String alamatPenerima;
    DateTime tanggalAmbil;
    String jenis;
    String sektor;
    String depo;
    String catatan;
    int jumlahContainer;
    String jenisContainer;
    String antriMuat;
    String selesaiMuat;
    String antriBongkar;
    String selesaiBongkar;
    String kembaliKeDepo;
    int tombolberangkat;
    int berangkat;

    factory SuratJalanModel.fromJson(Map<String, dynamic> json) => SuratJalanModel(
        id: json["ID"] == null ? null : json["ID"],
        idCustomernya: json["IdCustomernya"] == null ? null : json["IdCustomernya"],
        namaSupir: json["NamaSupir"] == null ? null : json["NamaSupir"],
        kodeTruck: json["KodeTruck"] == null ? null : json["KodeTruck"],
        idCustomer: json["IdCustomer"] == null ? null : json["IdCustomer"],
        kodeCustomer: json["KodeCustomer"],
        namaCustomer: json["NamaCustomer"] == null ? null : json["NamaCustomer"],
        buktiOrderTrucking: json["BuktiOrderTrucking"] == null ? null : json["BuktiOrderTrucking"],
        tanggalOrderTrucking: json["TanggalOrderTrucking"] == null ? null : DateTime.parse(json["TanggalOrderTrucking"]),
        namaPengirim: json["NamaPengirim"] == null ? null : json["NamaPengirim"],
        kotaPengirim: json["KotaPengirim"],
        alamatPengirim: json["AlamatPengirim"] == null ? null : json["AlamatPengirim"],
        namaPenerima: json["NamaPenerima"] == null ? null : json["NamaPenerima"],
        kotaPenerima: json["KotaPenerima"] == null ? null : json["KotaPenerima"],
        alamatPenerima: json["AlamatPenerima"] == null ? null : json["AlamatPenerima"],
        tanggalAmbil: json["TanggalAmbil"] == null ? null : DateTime.parse(json["TanggalAmbil"]),
        jenis: json["Jenis"] == null ? null : json["Jenis"],
        sektor: json["Sektor"] == null ? null : json["Sektor"],
        depo: json["Depo"] == null ? null : json["Depo"],
        catatan: json["Catatan"] == null ? null : json["Catatan"],
        jumlahContainer: json["JumlahContainer"] == null ? null : json["JumlahContainer"],
        jenisContainer: json["JenisContainer"] == null ? null : json["JenisContainer"],
        antriMuat: json["AntriMuat"] == null ? null : json["AntriMuat"],
        selesaiMuat: json["SelesaiMuat"] == null ? null : json["SelesaiMuat"],
        antriBongkar: json["AntriBongkar"] == null ? null : json["AntriBongkar"],
        selesaiBongkar: json["SelesaiBongkar"] == null ? null : json["SelesaiBongkar"],
        kembaliKeDepo: json["KembaliKeDepo"] == null ? null : json["KembaliKeDepo"],
        tombolberangkat: json["tombolberangkat"] == null ? null : json["tombolberangkat"],
        berangkat: json["Berangkat"] == null ? null : json["Berangkat"],
    );

    Map<String, dynamic> toJson() => {
        "ID": id == null ? null : id,
        "IdCustomernya": idCustomernya == null ? null : idCustomernya,
        "NamaSupir": namaSupir == null ? null : namaSupir,
        "KodeTruck": kodeTruck == null ? null : kodeTruck,
        "IdCustomer": idCustomer == null ? null : idCustomer,
        "KodeCustomer": kodeCustomer,
        "NamaCustomer": namaCustomer == null ? null : namaCustomer,
        "BuktiOrderTrucking": buktiOrderTrucking == null ? null : buktiOrderTrucking,
        "TanggalOrderTrucking": tanggalOrderTrucking == null ? null : "${tanggalOrderTrucking.year.toString().padLeft(4, '0')}-${tanggalOrderTrucking.month.toString().padLeft(2, '0')}-${tanggalOrderTrucking.day.toString().padLeft(2, '0')}",
        "NamaPengirim": namaPengirim == null ? null : namaPengirim,
        "KotaPengirim": kotaPengirim,
        "AlamatPengirim": alamatPengirim == null ? null : alamatPengirim,
        "NamaPenerima": namaPenerima == null ? null : namaPenerima,
        "KotaPenerima": kotaPenerima == null ? null : kotaPenerima,
        "AlamatPenerima": alamatPenerima == null ? null : alamatPenerima,
        "TanggalAmbil": tanggalAmbil == null ? null : "${tanggalAmbil.year.toString().padLeft(4, '0')}-${tanggalAmbil.month.toString().padLeft(2, '0')}-${tanggalAmbil.day.toString().padLeft(2, '0')}",
        "Jenis": jenis == null ? null : jenis,
        "Sektor": sektor == null ? null : sektor,
        "Depo": depo == null ? null : depo,
        "Catatan": catatan == null ? null : catatan,
        "JumlahContainer": jumlahContainer == null ? null : jumlahContainer,
        "JenisContainer": jenisContainer == null ? null : jenisContainer,
        "AntriMuat": antriMuat == null ? null : antriMuat,
        "SelesaiMuat": selesaiMuat == null ? null : selesaiMuat,
        "AntriBongkar": antriBongkar == null ? null : antriBongkar,
        "SelesaiBongkar": selesaiBongkar == null ? null : selesaiBongkar,
        "KembaliKeDepo": kembaliKeDepo == null ? null : kembaliKeDepo,
        "tombolberangkat": tombolberangkat == null ? null : tombolberangkat,
        "Berangkat": berangkat == null ? null : berangkat,
    };
}
