
package com.coforge.qa.runner;

import io.karatelabs.core.Runner;
import io.karatelabs.core.SuiteResult;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class UsuariosRunnerTest {

    private static final int DEFAULT_THREADS = 5;

    @Test
    void testUsuariosEnParalelo() {

        String tags = System.getProperty("karate.tags", "~@ignore");
        String path = System.getProperty(
        "karate.path",
        "src/test/resources/features"
);

        int threads = Integer.parseInt(
                System.getProperty(
                        "karate.threads",
                        String.valueOf(DEFAULT_THREADS)
                )
        );

        SuiteResult results = Runner.path(path)
                .tags(tags)
                .outputHtmlReport(true)
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .parallel(threads);

        assertEquals(
                0,
                results.getScenarioFailedCount(),
                String.join("\n", results.getErrors())
        );
    }
}
