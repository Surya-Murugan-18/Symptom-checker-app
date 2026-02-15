package com.sevai.sevaibackend.repository;

import com.sevai.sevaibackend.entity.Article;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ArticleRepository extends JpaRepository<Article, Long> {
    List<Article> findByCategoryIgnoreCase(String category);

    List<Article> findAllByOrderByPublishedDateDesc();
}
