package com.example.Flea_Market_Network.controller;

//MVC コントローラのアノテーション
import org.springframework.stereotype.Controller;
//GET ハンドラのアノテーション
import org.springframework.web.bind.annotation.GetMapping;
//ビューとモデルを返すための型
import org.springframework.web.servlet.ModelAndView;

//MVC コントローラとして登録
@Controller
public class LoginController {
	//ルートパス（/）にアクセスした場合は商品一覧ページへ直接フォワード（リダイレクトではなく）
	@GetMapping("/")
	public String root() {
		//商品一覧ページへフォワード（リダイレクトではなく、URLは変わらない）
		return "forward:/items";
	}

	//ログインページ表示のハンドラ
	@GetMapping("/login")
	public ModelAndView login() {
		//login.html（Thymeleaf）を返す（ModelAndViewを使用して循環参照を回避）
		ModelAndView modelAndView = new ModelAndView();
		modelAndView.setViewName("login");
		return modelAndView;
	}
}