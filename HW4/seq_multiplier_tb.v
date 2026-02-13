`timescale 1ns/1ps
module seq_multiplier_tb;
    localparam N = 32;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [N-1:0] multiplicand, multiplier;

    wire [2*N-1:0] product;
    wire busy, done;

    always #5 clk = ~clk;

    seq_multiplier #(.N(N)) dut (
        .clk(clk), .rst(rst), .start(start),
        .multiplicand(multiplicand), .multiplier(multiplier),
        .product(product), .busy(busy), .done(done)
    );

    task pulse_start;
    begin
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
    end
    endtask

    task run_one_test(input [N-1:0] a, input [N-1:0] b);
        reg [2*N-1:0] ref;
        integer timeout;
    begin
        ref = $unsigned(a) * $unsigned(b);

        // apply inputs
        multiplicand = a;
        multiplier   = b;

        // start only when not busy
        wait (busy == 0);
        @(posedge clk);
        pulse_start();

        // wait done with timeout
        timeout = 0;
        while (done !== 1'b1) begin
            @(posedge clk);
            timeout = timeout + 1;
            if (timeout > (2*N + 20)) begin
                $fatal(1, "TIMEOUT! a=%0d b=%0d", a, b);
            end
        end

        // check
        if (product !== ref) begin
            $fatal(1, "FAIL a=%h b=%h | got=%h ref=%h", a, b, product, ref);
        end else begin
            $display("PASS a=%h b=%h | product=%h", a, b, product);
        end
    end
    endtask

    integer i;
    initial begin
        multiplicand = 0;
        multiplier   = 0;

        // reset (sync)
        repeat (2) @(posedge clk);
        rst = 0;

        // directed tests
        run_one_test(0, 0);
        run_one_test(0, 32'h1234);
        run_one_test(1, 1);
        run_one_test(1, 32'hFFFF_FFFF);
        run_one_test(32'hFFFF_FFFF, 32'hFFFF_FFFF);
        run_one_test(32'h8000_0000, 2);
        run_one_test(32'h4000_0000, 4);

        // random tests
        for (i = 0; i < 50; i = i + 1) begin
            run_one_test($random, $random);
        end

        $display("TB FINISHED - ALL PASS");
        $finish;
    end
endmodule
