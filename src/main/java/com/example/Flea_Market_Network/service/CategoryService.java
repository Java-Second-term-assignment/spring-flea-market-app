package com.example.Flea_Market_Network.service;

//コレクション操作のための import
import java.util.List;
//Optional の import
import java.util.Optional;

//サービスアノテーションの import
import org.springframework.stereotype.Service;

//カテゴリエンティティの import
import com.example.Flea_Market_Network.entity.Category;
//カテゴリ用リポジトリの import
import com.example.Flea_Market_Network.repository.CategoryRepository;

//サービス層としての宣言
@Service
public class CategoryService {
	//リポジトリの参照
	private final CategoryRepository categoryRepository;

	//依存性をコンストラクタで注入
	public CategoryService(CategoryRepository categoryRepository) {
		//カテゴリリポジトリを設定
		this.categoryRepository = categoryRepository;
	}

	//全カテゴリ一覧を返す
	public List<Category> getAllCategories() {
		return categoryRepository.findAll();
	}

	//ID でカテゴリを取得
	public Optional<Category> getCategoryById(Long id) {
		return categoryRepository.findById(id);
	}

	//カテゴリを保存/更新
	public Category saveCategory(Category category) {
		//カテゴリ名が一意であることを確認
		if (categoryRepository.findByName(category.getName()).isPresent() &&
				(category.getId() == null
						|| !categoryRepository.findByName(category.getName()).get().getId().equals(category.getId()))) {
			throw new IllegalArgumentException("Category name already exists.");
		}
		return categoryRepository.save(category);
	}

	//カテゴリを削除
	public void deleteCategory(Long id) {
		categoryRepository.deleteById(id);
	}

	public boolean isCategoryExist(Long categoryId) {
		// categoryId が null でなければ、リポジトリに存在確認を委譲する
		if (categoryId == null) {
			return false;
		}
		return categoryRepository.existsById(categoryId);
	}
}