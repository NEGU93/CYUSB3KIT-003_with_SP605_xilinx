namespace Template
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.FOpenDialog = new System.Windows.Forms.OpenFileDialog();
            this.StatLabel = new System.Windows.Forms.StatusStrip();
            this.StatLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
            this.button2 = new System.Windows.Forms.Button();
            this.button3 = new System.Windows.Forms.Button();
            this.button1 = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.rtConsole = new System.Windows.Forms.RichTextBox();
            this.StatLabel.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // FOpenDialog
            // 
            this.FOpenDialog.FileName = "openFileDialog1";
            // 
            // StatLabel
            // 
            this.StatLabel.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.StatLabel1});
            this.StatLabel.Location = new System.Drawing.Point(0, 246);
            this.StatLabel.Name = "StatLabel";
            this.StatLabel.Size = new System.Drawing.Size(445, 22);
            this.StatLabel.TabIndex = 6;
            this.StatLabel.Text = "statusStrip1";
            // 
            // StatLabel1
            // 
            this.StatLabel1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.StatLabel1.Name = "StatLabel1";
            this.StatLabel1.Size = new System.Drawing.Size(128, 17);
            this.StatLabel1.Text = "toolStripStatusLabel1";
            // 
            // button2
            // 
            this.button2.Location = new System.Drawing.Point(297, 44);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(130, 29);
            this.button2.TabIndex = 8;
            this.button2.Text = "Configure";
            this.button2.UseVisualStyleBackColor = true;
            this.button2.Click += new System.EventHandler(this.button2_Click_1);
            // 
            // button3
            // 
            this.button3.Location = new System.Drawing.Point(11, 44);
            this.button3.Name = "button3";
            this.button3.Size = new System.Drawing.Size(130, 29);
            this.button3.TabIndex = 5;
            this.button3.Text = "Select Bitstream";
            this.button3.UseVisualStyleBackColor = true;
            this.button3.Click += new System.EventHandler(this.button3_Click);
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(156, 13);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(134, 27);
            this.button1.TabIndex = 9;
            this.button1.Text = "Download Firmware";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(0, 11);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(0, 13);
            this.label1.TabIndex = 10;
            this.label1.Click += new System.EventHandler(this.label1_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.button1);
            this.groupBox1.Controls.Add(this.button3);
            this.groupBox1.Controls.Add(this.button2);
            this.groupBox1.Location = new System.Drawing.Point(6, 2);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(434, 82);
            this.groupBox1.TabIndex = 11;
            this.groupBox1.TabStop = false;
            // 
            // rtConsole
            // 
            this.rtConsole.Location = new System.Drawing.Point(7, 90);
            this.rtConsole.Name = "rtConsole";
            this.rtConsole.Size = new System.Drawing.Size(433, 153);
            this.rtConsole.TabIndex = 12;
            this.rtConsole.Text = "";
            this.rtConsole.TextChanged += new System.EventHandler(this.rtConsole_TextChanged);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(445, 268);
            this.Controls.Add(this.rtConsole);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.StatLabel);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Form1";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "FPGA Configuration Utility";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.StatLabel.ResumeLayout(false);
            this.StatLabel.PerformLayout();
            this.groupBox1.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.OpenFileDialog FOpenDialog;
        private System.Windows.Forms.StatusStrip StatLabel;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button button3;
        private System.Windows.Forms.ToolStripStatusLabel StatLabel1;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.RichTextBox rtConsole;
    }
}

