module FA(
    input wire a,
    input wire b,
    input wire cin,
    output wire cout,
    output wire s
);
    wire axorb, and1, and2;
    xor u1(axorb, a, b); 
    xor u2(s, axorb, cin);
    and u3(and1, a, b);
    and u4(and2, cin, axorb);
    or u5(cout, and1, and2);
endmodule