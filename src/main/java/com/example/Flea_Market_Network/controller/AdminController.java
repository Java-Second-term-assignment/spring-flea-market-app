package com.example.Flea_Market_Network.controller;

//入出力例外に備えるための import
import java.io.IOException;
//CSV 出力に使用する Writer の import
import java.io.PrintWriter;
//期間指定に使う LocalDate の import
import java.time.LocalDate;

//サーブレットの HTTP レスポンスの import
import jakarta.servlet.http.HttpServletResponse;

//日付パラメタをフォーマットするアノテーションの import
import org.springframework.format.annotation.DateTimeFormat;
//メソッドレベル認可を使うためのアノテーション（EnableMethodSecurity が前提）
import org.springframework.security.access.prepost.PreAuthorize;
//MVC コントローラのアノテーション
import org.springframework.stereotype.Controller;
//画面に値を渡す Model の import
import org.springframework.ui.Model;
//ルーティングアノテーション群の import
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

//注文サービスの import
import com.example.Flea_Market_Network.service.AppOrderService;
//商品サービスの import
import com.example.Flea_Market_Network.service.ItemService;
//ユーザサービスの import
import com.example.Flea_Market_Network.service.UserService;

//MVC コントローラであることを示す
@Controller
///admin 配下のルーティングを担当
@RequestMapping("/admin")
//このコントローラは ADMIN ロールのみアクセス可
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {
	//商品サービスの参照
	private final ItemService itemService;
	//注文サービスの参照
	private final AppOrderService appOrderService;
	//ユーザサービスの参照
	private final UserService userService;

	//依存関係をコンストラクタで注入
	public AdminController(ItemService itemService, AppOrderService appOrderService,
			UserService userService) {
		// 商品サービスを設定
		this.itemService = itemService;
		// 注文サービスを設定
		this.appOrderService = appOrderService;
		// ユーザサービスを設定
		this.userService = userService;
	}

	// 商品管理画面の表示
	@GetMapping("/items")
	public String manageItems(Model model) {
		// すべての商品を取得
		model.addAttribute("items", itemService.getAllItems());
		// 管理画面テンプレートを返却
		return "admin_items";
	}

	// 管理者による商品削除
	@PostMapping("/items/{id}/delete")
	public String deleteItemByAdmin(@PathVariable Long id) {
		// 商品 ID を指定して削除
		itemService.deleteItem(id);
		// 削除成功のクエリパラメタ付きで一覧へ
		return "redirect:/admin/items?success=deleted";
	}

	// ユーザ管理画面の表示
	@GetMapping("/users")
	public String manageUsers(Model model) {
		// 全ユーザを取得
		model.addAttribute("users", userService.getAllUsers());
		// ユーザ管理テンプレートを返却
		return "admin_users";
	}

	// ユーザの有効/無効をトグル
	@PostMapping("/users/{id}/toggle-enabled")
	public String toggleUserEnabled(@PathVariable Long id) {
		// サービスで有効フラグを反転
		userService.toggleUserEnabled(id);
		// 成功パラメタを付けて戻る
		return "redirect:/admin/users?success=toggled";
	}

	// 統計ダッシュボードの表示
	@GetMapping("/statistics")
	public String showStatistics(
			// 開始日 (未指定なら 1 ヶ月前)
			@RequestParam(value = "startDate", required = false)
			@DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
			// 終了日 (未指定なら本日)
			@RequestParam(value = "endDate", required = false)
			@DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
			Model model) {

		// 開始日デフォルトを設定
		if (startDate == null)
			startDate = LocalDate.now().minusMonths(1);
		// 終了日デフォルトを設定
		if (endDate == null)
			endDate = LocalDate.now();

		// 期間をモデルへセット
		model.addAttribute("startDate", startDate);
		// 終了日をモデルへセット
		model.addAttribute("endDate", endDate);

		// 総売上を計算してモデルへ
		model.addAttribute("totalSales", appOrderService.getTotalSales(startDate, endDate));
		// ステータス別件数をモデルへ
		model.addAttribute("orderCountByStatus", appOrderService.getOrderCountByStatus(startDate, endDate));

		// 統計画面テンプレートを返却
		return "admin_statistics";
	}

	// 統計 CSV のエクスポート
	@GetMapping("/statistics/csv")
	public void exportStatisticsCsv(
			// 開始日（任意）
			@RequestParam(value = "startDate", required = false)
			@DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
			// 終了日（任意）
			@RequestParam(value = "endDate", required = false)
			@DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
			HttpServletResponse response) throws IOException {

		// デフォルト開始日
		if (startDate == null)
			startDate = LocalDate.now().minusMonths(1);
		// デフォルト終了日
		if (endDate == null)
			endDate = LocalDate.now();

		// コンテンツタイプを CSV に設定（UTF-8）
		response.setContentType("text/csv; charset=UTF-8");
		// ダウンロードファイル名を設定
		response.setHeader("Content-Disposition", "attachment; filename=\"flea_market_statistics.csv\"");

		// try-with-resources で Writer を確実にクローズ
		try (PrintWriter writer = response.getWriter()) {
			// 期間の見出しを書き出す
			writer.append("統計期間: " + startDate + " から " + endDate + "\n\n");
			// 総売上を書き出す
			writer.append("総売上: " + appOrderService.getTotalSales(startDate, endDate) + "\n\n");
			// ステータス別の見出し
			writer.append("ステータス別注文数\n");

			// ステータス別件数を 1 行ずつ出力
			appOrderService.getOrderCountByStatus(startDate, endDate).forEach((status, count) -> {
				// CSV1 行を出力
				writer.append(status + "," + count + "\n");
			});
			// ここで PrintWriter が自動的に close され、レスポンスがフラッシュされる
		}
	}
}