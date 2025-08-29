//
//  LocalizationManager.swift
//  portos
//
//  Created by James Silaban on 27/08/25.
//

import Foundation
import SwiftUI

enum ActiveSetting: Identifiable {
    case currency, language
    var id: Int { hashValue }
}

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: Language = .indonesia
    @Published var currentCurrency: Currency = .idr
    @Published var showCash: Bool = true
    
    static let shared = LocalizationManager()
    
    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguage) {
            currentLanguage = language
        } else {
            currentLanguage = .indonesia
        }
        
        if let savedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency"),
           let currency = Currency(rawValue: savedCurrency) {
            currentCurrency = currency
        } else {
            currentCurrency = .idr
        }
        
        // Load showCash preference from UserDefaults
        showCash = UserDefaults.standard.bool(forKey: "showCash")
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "selectedLanguage")
    }
    
    func setCurrency(_ currency: Currency) {
        currentCurrency = currency
        UserDefaults.standard.set(currency.rawValue, forKey: "selectedCurrency")
    }
    
    func setShowCash(_ show: Bool) {
        showCash = show
        UserDefaults.standard.set(show, forKey: "showCash")
    }
    
    func localizedString(_ key: String) -> String {
        return LocalizedStrings.getString(key, language: currentLanguage)
    }
}

struct LocalizedStrings {
    static func getString(_ key: String, language: Language) -> String {
        switch language {
        case .indonesia: return indonesianStrings[key] ?? key
        case .english: return englishStrings[key] ?? key
        }
    }
    
    private static let indonesianStrings: [String: String] = [
        // Portfolio Screen
        "all": "Semua",
        "history": "Riwayat",
        "add": "Tambah",
        "more": "Lainnya",
        "settings": "Pengaturan",
        "edit_portfolio": "Edit Portfolio",
        "delete_portfolio": "Hapus Portfolio",
        "no_portfolio": "Tidak Ada Portfolio",
        "no_asset": "Tidak Ada Aset",
        "create_portfolio_message": "Buat portfolio, dan mereka akan muncul di sini.",
        "try_add_asset_message": "Coba tambahkan aset, dan mereka akan ditampilkan di sini.",
        "view_more": "Lihat Lebih Banyak",
        "view_less": "Lihat Lebih Sedikit",
        "delete_permanently": "Hapus Permanen",
        "delete_confirmation_message": "Tindakan ini tidak dapat dibatalkan, apakah Anda yakin ingin menghapus portfolio ini?",
        "delete": "Hapus",
        "cancel": "Batal",
        "edit": "Edit",
        
        // Add Portfolio
        "create_portfolio": "Buat Portfolio",
        "edit_portfolio_title": "Edit Portfolio",
        "confirm": "Konfirmasi",
        "save": "Simpan",
        "title": "Judul",
        "target_amount": "Jumlah Target",
        "type_amount": "Ketik Jumlah...",
        "term": "Jangka Waktu",
        "years": "Tahun",
        
        // Trade Transaction
        "adding": "Menambahkan",
        "liquidating": "Melikuidasi",
        "edit_transaction": "Edit Transaksi",
        "purchase_date": "Tanggal Pembelian",
        "liquidate_date": "Tanggal Likuidasi",
        "amount": "Jumlah",
        "price": "Harga",
        "total": "Total",
        "date": "Tanggal",
        "notes": "Catatan",
        "add_notes": "Tambahkan catatan...",
        "confirm_transaction": "Konfirmasi Transaksi",
        "transaction_successful": "Transaksi Berhasil",
        "transaction_failed": "Transaksi Gagal",
        
        // Transfer Transaction
        "transfer": "Transfer",
        "from": "Dari",
        "to": "Ke",
        "transfer_amount": "Jumlah Transfer",
        "transfer_date": "Tanggal Transfer",
        "transfer_notes": "Catatan Transfer",
        
        // Search Asset
        "choose_asset_to_add": "Pilih aset untuk ditambahkan",
        "search": "Cari",
        "search_prompt": "Cari aset...",
        
        // Settings
        "currency": "Mata Uang",
        "language": "Bahasa",
        "general": "Umum",
        
        // Charts and Empty States
        "no_assets_yet": "Belum Ada Aset",
        "start_building_portfolio": "Mulai membangun portfolio Anda dengan menambahkan aset pertama",
        "no_asset_allocation": "Tidak Ada Alokasi Aset",
        "start_building_portfolio_short": "Mulai membangun portfolio Anda",
        
        // Transaction Details
        "traded_in": "Diperdagangkan dalam",
        "note_lot_info": "Catatan: 1 Lot = 100 Saham",
        "select_platform": "Pilih Platform",
        "select_portfolio": "Pilih Portfolio",
        "platform": "Platform",
        "portfolio": "Portfolio",
        
        // Price Labels
        "current_price": "Harga Saat Ini",
        "average_price": "Harga Rata-rata",
        
        // Common
        "back": "Kembali",
        "close": "Tutup",
        "ok": "OK",
        "yes": "Ya",
        "no": "Tidak",
        "loading": "Memuat...",
        "error": "Error",
        "success": "Berhasil",
        "warning": "Peringatan",
        "info": "Informasi",
        "done": "Selesai",
        "no_history": "Tidak Ada Riwayat",
        "no_history_message": "Ketika Anda menambahkan, melikuidasi, atau mentransfer aset, catatan mereka ada di sini.",
        "today": "Hari Ini",
        "currency_idr": "Rp",
        "transferring": "Mentransfer",
        "target_amount_required": "Jumlah target diperlukan",
        "name_required": "Nama diperlukan",
        "save_failed": "Simpan gagal",
        "invalid_url": "URL Tidak Valid",
        "decoding_failed": "Dekoding Gagal",
        "request_failed": "Permintaan Gagal",
        "unknown_error": "Error Tidak Diketahui",
        "http_error": "Error HTTP",
        "api_failed": "API Gagal",
        "map_failed_at": "Map gagal pada",
        "try": "Coba",
        "ytd": "YTD",
        "missing_cost_basis_per_unit_on_sell": "Missing costBasisPerUnit on sell",
        "lot": "lot",
        "indonesia": "Indonesia",
        "english": "English"
    ]
    
    private static let englishStrings: [String: String] = [
        // Portfolio Screen
        "all": "All",
        "history": "History",
        "add": "Add",
        "more": "More",
        "settings": "Settings",
        "edit_portfolio": "Edit Portfolio",
        "delete_portfolio": "Delete Portfolio",
        "no_portfolio": "No Portfolio",
        "no_asset": "No Asset",
        "create_portfolio_message": "Create portfolios, and they will be here.",
        "try_add_asset_message": "Try add an asset, and it will be shown here.",
        "view_more": "View More",
        "view_less": "View Less",
        "delete_permanently": "Delete Permanently",
        "delete_confirmation_message": "This action cannot be undone, are you sure to delete this portfolio?",
        "delete": "Delete",
        "cancel": "Cancel",
        "edit": "Edit",
        
        // Add Portfolio
        "create_portfolio": "Create Portfolio",
        "edit_portfolio_title": "Edit Portfolio",
        "confirm": "Confirm",
        "save": "Save",
        "title": "Title",
        "target_amount": "Target Amount",
        "type_amount": "Type Amount...",
        "term": "Term",
        "years": "Years",
        
        // Trade Transaction
        "adding": "Adding",
        "liquidating": "Liquidating",
        "edit_transaction": "Edit Transaction",
        "purchase_date": "Purchase Date",
        "liquidate_date": "Liquidate Date",
        "amount": "Amount",
        "price": "Price",
        "total": "Total",
        "date": "Date",
        "notes": "Notes",
        "add_notes": "Add notes...",
        "confirm_transaction": "Confirm Transaction",
        "transaction_successful": "Transaction Successful",
        "transaction_failed": "Transaction Failed",
        
        // Transfer Transaction
        "transfer": "Transfer",
        "from": "From",
        "to": "To",
        "transfer_amount": "Transfer Amount",
        "transfer_date": "Transfer Date",
        "transfer_notes": "Transfer Notes",
        
        // Search Asset
        "choose_asset_to_add": "Choose asset to add",
        "search": "Search",
        "search_prompt": "Search assets...",
        
        // Settings
        "currency": "Currency",
        "language": "Language",
        "general": "General",
        
        // Charts and Empty States
        "no_assets_yet": "No Assets Yet",
        "start_building_portfolio": "Start building your portfolio by adding your first asset",
        "no_asset_allocation": "No Asset Allocation",
        "start_building_portfolio_short": "Start building your portfolio",
        
        // Transaction Details
        "traded_in": "Traded in",
        "note_lot_info": "Note: 1 Lot = 100 Shares",
        "select_platform": "Select Platform",
        "select_portfolio": "Select Portfolio",
        "platform": "Platform",
        "portfolio": "Portfolio",
        
        // Price Labels
        "current_price": "Current Price",
        "average_price": "Average Price",
        
        // Common
        "back": "Back",
        "close": "Close",
        "ok": "OK",
        "yes": "Yes",
        "no": "No",
        "loading": "Loading...",
        "error": "Error",
        "success": "Success",
        "warning": "Warning",
        "info": "Info",
        "done": "Done",
        "no_history": "No History",
        "no_history_message": "When you add, liquidate, or transfer your assets, their records are here.",
        "today": "Today",
        "currency_idr": "Rp",
        "lot": "lot",
        "transferring": "Transferring",
        "target_amount_required": "Target amount is required",
        "name_required": "Name is required",
        "save_failed": "Save failed",
        "invalid_url": "Invalid URL",
        "decoding_failed": "Decoding Failed",
        "request_failed": "Request Failed",
        "unknown_error": "Unknown Error",
        "http_error": "HTTP Error",
        "api_failed": "API Failed",
        "map_failed_at": "Map failed at",
        "try": "Try",
        "ytd": "YTD",
        "missing_cost_basis_per_unit_on_sell": "Missing costBasisPerUnit on sell",
        "indonesia": "Indonesia",
        "english": "English"
    ]
}
