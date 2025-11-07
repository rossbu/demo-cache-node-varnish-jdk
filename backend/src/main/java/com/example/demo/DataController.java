package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.ResponseEntity;
import org.springframework.http.CacheControl;

import java.util.HashMap;
import java.util.Map;
import java.time.LocalDateTime;
import java.util.concurrent.TimeUnit;

@RestController
public class DataController {

    @GetMapping("/api/data")
    public ResponseEntity<Map<String, Object>> getData() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Hello from Spring Boot Backend!");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("data", Map.of(
            "id", 1,
            "name", "Sample Data",
            "description", "This is mock JSON data from the backend"
        ));
        
        return ResponseEntity.ok()
            .cacheControl(CacheControl.maxAge(60, TimeUnit.SECONDS).cachePublic())
            .body(response);
    }
}
