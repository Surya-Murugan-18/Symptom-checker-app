package com.sevai.sevaibackend.controller;

import com.sevai.sevaibackend.entity.Article;
import com.sevai.sevaibackend.repository.ArticleRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/articles")
@CrossOrigin(origins = "*")
public class ArticleController {

    private final ArticleRepository articleRepo;

    public ArticleController(ArticleRepository articleRepo) {
        this.articleRepo = articleRepo;
    }

    @GetMapping
    public List<Article> getAll() {
        return articleRepo.findAllByOrderByPublishedDateDesc();
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id) {
        return articleRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/category/{category}")
    public List<Article> getByCategory(@PathVariable String category) {
        return articleRepo.findByCategoryIgnoreCase(category);
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Article article) {
        return ResponseEntity.ok(articleRepo.save(article));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        articleRepo.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
